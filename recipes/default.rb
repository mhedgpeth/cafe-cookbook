#
# Cookbook:: cafe
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'vcruntime::vc14'

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
cafe_install_directory = "#{install_root}/cafe"
cafe_cache_directory = "#{Chef::Config['file_cache_path']}/cafe"
cafe_archive_cached = "#{cafe_cache_directory}/#{cafe_archive}"

directory 'cafe cache directory' do
  path cafe_cache_directory
end

remote_file cafe_archive_cached do
  source "https://github.com/mhedgpeth/cafe/releases/download/#{cafe_github_version}/#{cafe_archive}"
  notifies :delete, 'directory[cafe cache directory]', :before
  notifies :create, 'directory[cafe cache directory]', :before
  notifies :unzip, 'windows_zipfile[unzip cafe]', :immediately
  notifies :run, 'execute[initialize cafe]', :immediately
  notifies :run, 'execute[register cafe]', :immediately
end

directory cafe_install_directory

windows_zipfile 'unzip cafe' do
  path cafe_install_directory
  source cafe_archive_cached
  action :nothing
end

execute 'initialize cafe' do
  command 'cafe init'
  cwd cafe_install_directory
  action :nothing
end

execute 'register cafe' do
  command 'cafe service register'
  cwd cafe_install_directory
  action :nothing
end

template "#{cafe_install_directory}/server.json" do
  source 'server.json.erb'
  variables(
    chef_interval: node['cafe']['chef_interval'],
    port: node['cafe']['port'],
    install_root: install_root
  )
  notifies :restart, 'service[cafe]', :immediately
end

service 'cafe' do
    action :start
end