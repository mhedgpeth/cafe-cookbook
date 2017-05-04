resource_name :cafe_installed

property :download_source, String, required: true
property :download_checksum, String, required: false
property :version, String, required: true
property :installer, String, required: true
property :cafe_install_root, String, default: 'C:'
property :chef_interval, Integer, default: 1800
property :service_port, Integer, default: 59320

default_action :install

action :install do
  include_recipe 'vcruntime::vc14'

  cafe_install_location = "#{cafe_install_root}/cafe"
  is_installed = ::File.exist? '{cafe_install_location}/cafe.exe'

  if is_installed
    Chef::Log.info 'Chef is already installed, so upgrading it through the chef.Updater'
    remote_file "#{cafe_install_location}/staging/#{installer}" do
      source download_source
      checksum download_checksum
      notifies :run, 'execute[upgrade cafe]', :delayed
    end

    execute 'upgrade cafe' do
      action :nothing
      cwd cafe_install_location
      command "cafe upgrade version: #{version}"
      not_if "cafe version? #{version}"
    end
  else
    cafe_cache_directory = "#{Chef::Config['file_cache_path']}/cafe"
    cafe_archive_cached = "#{cafe_cache_directory}/#{installer}"
    directory 'cafe cache directory' do
      recursive true
      path cafe_cache_directory
    end

    remote_file cafe_archive_cached do
      source download_source
      checksum download_checksum
      notifies :delete, 'directory[cafe cache directory]', :before
      notifies :create, 'directory[cafe cache directory]', :before
      notifies :unzip, 'windows_zipfile[unzip cafe]', :immediately
      notifies :run, 'execute[initialize cafe]', :immediately
      notifies :run, 'execute[register cafe]', :immediately
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

  end

  execute 'register cafe.Updater' do
    command 'cafe.Updater service register'
    cwd "#{cafe_install_location}/updater"
    guard_interpreter :powershell_script
    only_if '!(Get-Service -Name "cafe.Updater" -ErrorAction SilentlyContinue)'
  end


  template "#{cafe_install_location}/server.json" do
    source 'server.json.erb'
    variables(
      chef_interval: chef_interval,
      port: service_port,
      install_root: cafe_install_root
    )
  end

  service 'cafe' do
    action :start
  end

  service 'cafe.Updater' do
    action :start
  end
end
