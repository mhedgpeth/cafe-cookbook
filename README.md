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

## `cafe` resource

To install and configure Cafe, you should use the `cafe` resource, for example:

```ruby
cafe 'cafe' do
  download_source 'https://github.com/mhedgpeth/cafe/releases/download/0.9.2-beta/cafe-win10-x64-0.9.2.0.zip'
  download_checksum '75707978E48B51EC9564D209A9B6CA8F4B563AC4B128C34614435899FAD787C7'
  version '0.9.2.0'
  installer 'cafe-win10-x64-0.9.2.0.zip'
  cafe_install_root 'D:'
  chef_interval 1800
  service_port 59320
end
```

See the [Cafe Releases](https://github.com/mhedgpeth/cafe/releases) page to get the `download_source`, `version`, and `installer` that you need to use. You'll have to calculate your own checksum at the moment. The last three properties are configuration elements of Cafe itself; if you omit them, the resource will use sensible default values.

You should also notice that this resource is very friendly to air-gapped environments; you can use any URL you need to use here, as long as you get it downloaded and it matches the checksum. We use [artifactory](https://www.jfrog.com/artifactory/) for our artifacts and love it.

If you are introducing Cafe to existing Chef nodes because you want to manage Chef that way now, and your `cafe_install_root` is set to `D:`, it will dutifully install Cafe for the first time in `D:\chef`. On an upgrade, the `cafe` service asks its `cafe Updater` service friend to update `cafe` for it, because services can't update themselves. This all happens after the Chef run is finished, assuming that Cafe is running Chef.

## `cafe_chef` resource

You'll also want to keep the `chef-client` application up to date and consistent on all of your nodes. You'll want to make sure you do this when Chef is not running as well. Fortunately, Cafe has you covered in this regard. Simply declare what you want Chef to look like on the machine, and Cafe handles the rest:

```ruby
cafe_chef 'chef-client' do
  download_source 'https://packages.chef.io/files/stable/chef/13.0.118/windows/2012r2/chef-client-13.0.118-1-x64.msi'
  installer 'chef-client-13.0.118-1-x64.msi'
  download_checksum 'c594965648e20a2339d6f33d236b4e3e22b2be6916cceb1b0f338c74378c03da'
  version '13.0.118'
  cafe_install_root 'D:'
end
```

As with the scenario above, you can use any source you want from a private repository like artifactory. This is the equivalent of running `cafe chef download 13.0.118` and then `cafe install chef 13.0.118` but gives you more control to download the file.
 
Also, you can omit the `cafe_install_root` if you want to install everything on `C:`.

It's important to understand what exactly is happening here, because this is at the genesis of why Cafe exists. You would expect Cafe to be *running* Chef at this moment, so you don't want it to upgrade Chef immediately. So here we're **not** upgrading Chef, we're **requesting** that Cafe upgrade Chef after the Chef client runs. The _desired state_ of the system is "I want Cafe to make the Chef client be on version 13.0.118". Cafe handles the rest!

So you don't need to worry about timing here. Cafe runs **all** of its jobs sequentially because it knows that you don't want things stepping on other things. So sleep peacefully, my friend!
