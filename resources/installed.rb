resource_name :installed

property :github_version, String, required: true, name_property: true
property :version, String, required: true
property :installer, String, required: true
property :cafe_install_root, String, default: 'C:'
property :chef_interval, Integer, default: 1800
property :service_port, Integer, default: 59320

action :install do
  include_recipe 'vcruntime::vc14'

  cafe_install_location = "#{install_root}/cafe"
  cafe_cache_directory = "#{Chef::Config['file_cache_path']}/cafe"
  cafe_archive_cached = "#{cafe_cache_directory}/#{installer}"
  directory 'cafe cache directory' do
      recursive true
      path cafe_cache_directory
  end

  remote_file cafe_archive_cached do
    source "https://github.com/mhedgpeth/cafe/releases/download/#{github_version}/#{installer}"
    notifies :delete, 'directory[cafe cache directory]', :before
    notifies :create, 'directory[cafe cache directory]', :before
    notifies :stop, 'service[stop cafe]', :before
    notifies :unzip, 'windows_zipfile[unzip cafe]', :immediately
    notifies :run, 'execute[initialize cafe]', :immediately
    notifies :run, 'execute[register cafe]', :immediately
  end

  service 'stop cafe' do
    action :nothing
    service_name 'cafe'
    guard_interpreter :powershell_script
    only_if '!!(Get-Service -Name "cafe" -ErrorAction SilentlyContinue)'
  end

  directory cafe_install_location

  windows_zipfile 'unzip cafe' do
    path cafe_install_location
    source cafe_archive_cached
    action :nothing
  end

  execute 'initialize cafe' do
    command 'cafe init'
    cwd cafe_install_location
    action :nothing
  end

  execute 'register cafe' do
    command 'cafe service register'
    cwd cafe_install_location
    action :nothing
    guard_interpreter :powershell_script
    only_if '!(Get-Service -Name "cafe" -ErrorAction SilentlyContinue)'
  end

  template "#{cafe_install_location}/server.json" do
    source 'server.json.erb'
    variables(
        chef_interval: chef_interval,
        port: service_port2,
        install_root: install_root
    )
    notifies :restart, 'service[cafe]', :immediately
  end

  service 'cafe' do
    action :start
  end
end