# cafe

This cookbook installs and configures cafe, an application that exists to make running Chef more delightful.

It has been tested on Windows 2008, 2012, and 2016 and will update the latest version of cafe.

# Recipes

I recommend managing cafe through the custom resources in the cookbook. However, if you want to use the `default` recipe and the cookbook attributes to keep cafe up and running, you may.

The attributes that are important are all under the `cafe` subheading:

| Attribute      | Description                                     |
|----------------|-------------------------------------------------|
| chef_interval  | How often (in seconds) you want to run chef     |
| port           | which port you want to use to run cafe on       |
| install_root   | which drive you want cafe and chef installed on |
| version        | the cafe version you want installed             |
| version_github | the cafe github version you want installed      |

# Resources

## `cafe_installed`

To install and configure cafe, you can use the `cafe_installed` resource:

```ruby
cafe_installed '0.5.4-beta' do
  version '0.5.4.0'
  installer 'cafe-win10-x64-0.5.4.0.zip'
  cafe_install_root 'D:'
  chef_interval 1800
  service_port 59320
end
```

See the [Cafe Releases](https://github.com/mhedgpeth/cafe/releases) page to get the `github_version` (name property), `version`, and `installer` that you need to use. The last three are configuration elements of cafe itself; if you omit them, the resource will use sensible default values.

## `cafe_chef_installed`

You can also use the cafe cookbook to keep your chef client on the appropriate version. Do this with the `cafe_chef_installed` resource:

```ruby
cafe_chef_installed 'chef-client 13.0.118' do
  version '13.0.118'
  cafe_install_location 'D:/cafe'
end
```
 
You can omit the `cafe_install_location` if it is in the default `C:/cafe` location. Also, using this resource assumes that you have staged it in the `staging` directory within the cafe install location. For example, if you have cafe installed at `C:/cafe` and you want to install version `13.0.118` of the chef client, you'll need to make sure that the installer `chef-client-13.0.118-1-x64.msi` is located in the `C:/cafe/staging` directory. 

## `cafe_chef_staged`

If you want the cookbook to stage the file for you, use this resource:

```ruby
cafe_chef_staged 'chef-client staged for 13.0.118' do
  source 'https://packages.chef.io/files/stable/chef/13.0.118/windows/2012r2/chef-client-13.0.118-1-x64.msi'
  installer 'chef-client-13.0.118-1-x64.msi'
  checksum 'c594965648e20a2339d6f33d236b4e3e22b2be6916cceb1b0f338c74378c03da'
  cafe_install_location 'D:/cafe'
end
```
