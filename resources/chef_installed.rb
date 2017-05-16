resource_name :cafe_chef_installed

property :version, String, required: true
property :cafe_install_location, String, default: 'C:/cafe'

default_action :install

action :install do
  cafe_executable = "#{cafe_install_location}/cafe.exe"
  execute "install chef #{version}" do
    command "#{cafe_executable} chef install #{version} on: localhost return: immediately"
    not_if "#{cafe_executable} chef version? #{version}"
  end
end
