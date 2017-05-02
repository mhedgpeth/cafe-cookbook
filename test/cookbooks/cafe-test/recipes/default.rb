#
# Cookbook:: cafe_test
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

cafe_installed

cafe_chef_staged 'chef-client staged for 13.0.118' do
  source 'https://packages.chef.io/files/stable/chef/13.0.118/windows/2012r2/chef-client-13.0.118-1-x64.msi'
  installer 'chef-client-13.0.118-1-x64.msi'
  checksum 'c594965648e20a2339d6f33d236b4e3e22b2be6916cceb1b0f338c74378c03da'
  cafe_install_location 'D:/cafe'
end

cafe_chef_installed 'chef-client 13.0.118' do
  version '13.0.118'
  cafe_install_location 'D:/cafe'
end