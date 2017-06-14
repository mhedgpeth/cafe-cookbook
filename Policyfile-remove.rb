# Policyfile.rb - Describe how you want Chef to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name 'cafe'

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'recipe[cafe::default]', 'recipe[cafe-test::remove_cafe]'

# Specify a custom source for a single cookbook:
cookbook 'cafe', path: '.'
cookbook 'cafe-test', path: 'test/cookbooks/cafe-test'
