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

## `cafe_chef_staged`

You'll also want to keep the chef application up to date and consistent on all of your nodes. You'll want to make sure you do this when chef is not running as well. Fortunately, `cafe` has you covered in this regard. The first thing you'll want to do is stage the chef installation with `cafe`:

```ruby
cafe_chef_staged 'chef-client staged for 13.0.118' do
  source 'https://packages.chef.io/files/stable/chef/13.0.118/windows/2012r2/chef-client-13.0.118-1-x64.msi'
  installer 'chef-client-13.0.118-1-x64.msi'
  checksum 'c594965648e20a2339d6f33d236b4e3e22b2be6916cceb1b0f338c74378c03da'
  cafe_install_location 'D:/cafe'
end
```

As with the scenario above, you can use any source you want from a private repository. This is the equivalent of running `cafe chef download 13.0.118` but gives you more control to download the file.

## `cafe_chef_installed`

Once you have staged the chef installation, it's time to say that you want it to be installed. You'll do this with the `cafe_chef_installed` resource:

```ruby
cafe_chef_installed 'chef-client 13.0.118' do
  version '13.0.118'
  cafe_install_location 'D:/cafe'
end
```
 
You can omit the `cafe_install_location` if it is in the default `C:/cafe` location.

It's important to understand what exactly is happening here, because this is at the genesis of why cafe exists. You would expect cafe to be *running* chef at this moment, so you don't want it to upgrade chef immediately. So here we're **not** upgrading chef, we're **requesting** that cafe upgrade chef after the chef client runs. The _desired state_ of the system is "I want cafe to make the chef client be on version 13.0.118". Cafe handles the rest!

So you don't need to worry about timing here. Cafe runs **all** of its jobs serially because it knows that you don't want things stepping on other things. So sleep peacefully! 