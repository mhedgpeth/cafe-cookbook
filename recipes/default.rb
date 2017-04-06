#
# Cookbook:: cafe
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'vcruntime::vc14'

cafe_version = '0.5.3.0'
cafe_github_version = 'v0.5.3-beta'

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
cafe_install_directory = 'C:/cafe'
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

service 'cafe' do
    action :start
end