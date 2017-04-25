# # encoding: utf-8

# Inspec test for recipe cafe::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.24215') do
  it { should be_installed }
end

describe file('C:/cafe/cafe.exe') do
  it { should exist }
end

describe port(59320) do
  it { should be_listening }
end
