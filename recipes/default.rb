#
# Cookbook:: cafe
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

cafe_version = node['cafe']['version']
cafe_github_version = node['cafe']['version_github']

platform_version = node['platform_version']
cafe_platform = ::CafeSettings.runtime_identifier(platform_version)
Chef::Log.info "Expecting cafe to run on platform: #{cafe_platform}"

cafe_archive = ::CafeSettings.cafe_archive(cafe_platform, cafe_version)
install_root = node['cafe']['install_root']

source = "https://github.com/mhedgpeth/cafe/releases/download/#{cafe_github_version}/#{cafe_archive}"

cafe 'cafe' do
  download_source source
  version cafe_version
  installer cafe_archive
  cafe_install_root install_root
  chef_interval node['cafe']['chef_interval']
  service_port node['cafe']['port']
end
