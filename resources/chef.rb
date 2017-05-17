resource_name :cafe_chef

property :version, String
property :cafe_install_location, String, default: 'C:/cafe'
property :installer_source, String
property :installer, String
property :installer_checksum

default_action :install

action :install do
  cafe_executable = "#{cafe_install_location}/cafe.exe"
  execute "install chef #{version}" do
    command "#{cafe_executable} chef install #{version} on: localhost return: immediately"
    not_if "#{cafe_executable} chef version? #{version}"
  end
end

action :stage do
  staging_directory = "#{cafe_install_location}/staging"

  directory staging_directory do
    recursive true
  end

  installer_location = "#{staging_directory}/#{installer}"
  Chef::Log.info "Staging chef installer to #{installer_location}"
  remote_file installer_location do
    source installer_source
    checksum installer_checksum
  end
end
