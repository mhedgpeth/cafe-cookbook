#
# Cookbook:: cafe
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'vcruntime::vc14'

cafe_version = '0.5.3.0'
cafe_github_version = 'v0.5.3-beta'
cafe_archive = "cafe-win8-x64-#{cafe_version}.zip"
cafe_install_directory = 'C:/cafe'
cafe_archive_cached = "#{Chef::Config['file_cache_path']}/#{cafe_archive}"

remote_file cafe_archive_cached do
  source "https://github.com/mhedgpeth/cafe/releases/download/#{cafe_github_version}/#{cafe_archive}"
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