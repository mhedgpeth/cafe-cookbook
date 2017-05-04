resource_name :cafe_chef_staged

property :source, String, required: true
property :installer, String, required: true
property :checksum, String, required: false
property :cafe_install_location, String, default: 'C:/cafe'

default_action :download

action :download do
  staging_directory = "#{cafe_install_location}/staging"
  installer_location = "#{staging_directory}/#{installer}"
  Chef::Log.info "Staging chef installer to #{installer_location}"
  remote_file installer_location staging_directory do
    source source
    checksum checksum
  end
end
