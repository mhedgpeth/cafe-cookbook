cafe 'remove cafe' do
  action :remove
  version node['cafe']['version']
  cafe_install_root node['cafe']['install_root']
end
