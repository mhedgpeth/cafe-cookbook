resource_name :cafe

property :download_source, String
property :download_checksum, String
property :version, String
property :installer, String
property :cafe_install_root, String, default: 'C:'
property :chef_interval, Integer, default: 1800
property :service_port, Integer, default: 59320

default_action :install

def cafe_install_location
  "#{cafe_install_root}/cafe"
end

def cafe_executable
  "#{cafe_install_location}/cafe.exe"
end

def cafe_cached_directory
  "#{Chef::Config['file_cache_path']}/cafe"
end

action :install do
  include_recipe 'vcruntime::vc14'

  is_installed = ::File.exist? cafe_executable

  if is_installed
    Chef::Log.info 'Cafe is already installed, so upgrading it through the cafe.Updater'

    staging_directory = "#{cafe_install_location}/staging"

    directory staging_directory do
      recursive true
    end

    remote_file "#{staging_directory}/#{installer}" do
      source download_source
      checksum download_checksum
      notifies :run, 'execute[upgrade cafe]', :delayed
    end

    execute 'upgrade cafe' do
      action :nothing
      cwd cafe_install_location
      command "cafe install version: #{version} on: localhost return: immediately"
      not_if "cafe version? #{version}"
    end
  else
    Chef::Log.info "Cafe is not installed at #{cafe_executable}, so installing it for the first time"
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

    directory cafe_install_location do
      recursive true
    end

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
    cookbook 'cafe'
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

action :remove do
  directory cafe_cached_directory do
    action :delete
    recursive true
  end

  service 'cafe' do
    action :stop
    guard_interpreter :powershell_script
    only_if 'Get-Service -Name "cafe" -ErrorAction SilentlyContinue'
  end

  service 'cafe.Updater' do
    action :stop
    guard_interpreter :powershell_script
    only_if 'Get-Service -Name "cafe.Updater" -ErrorAction SilentlyContinue'
  end

  execute 'uninstall cafe service' do
    command "#{cafe_executable} service unregister"
    cwd cafe_install_location
    guard_interpreter :powershell_script
    only_if 'Get-Service -Name "cafe" -ErrorAction SilentlyContinue'
  end

  execute 'unregister cafe.Updater' do
    command 'cafe.Updater service unregister'
    cwd "#{cafe_install_location}/updater"
    guard_interpreter :powershell_script
    only_if 'Get-Service -Name "cafe.Updater" -ErrorAction SilentlyContinue'
  end

  directory cafe_install_location do
    action :delete
    recursive true
  end
end
