#
# Cookbook:: cafe
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

cafe_version = node['cafe']['version']
cafe_github_version = node['cafe']['version_github']

platform_version = node['platform_version']
cafe_platform = if platform_version.start_with? '6.1'
                  'win7'
                elsif platform_version.start_with? '6.3'
                  'win8'
                else
                  'win10'
                end
Chef::Log.info "Expecting cafe to run on platform: #{cafe_platform}"

cafe_archive = "cafe-#{cafe_platform}-x64-#{cafe_version}.zip"
install_root = node['cafe']['install_root']

download_source = "https://github.com/mhedgpeth/cafe/releases/download/#{cafe_github_version}/#{installer}"

cafe_installed 'cafe' do
  download_source download_source
  version cafe_version
  installer cafe_archive
  cafe_install_root install_root
  chef_interval node['cafe']['chef_interval']
  service_port node['cafe']['port']
end
