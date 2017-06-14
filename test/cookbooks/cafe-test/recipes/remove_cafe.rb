cafe 'remove cafe' do
  action :remove
  cafe_install_root node['cafe']['install_root']
end
