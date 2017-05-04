resource_name :cafe_chef_staged

property :installer_source, String, required: true
property :installer, String, required: true
property :installer_checksum, String, required: false
property :cafe_install_location, String, default: 'C:/cafe'

default_action :download

action :download do
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
