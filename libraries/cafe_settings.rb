class CafeSettings
  def self.runtime_identifier(platform_version)
    if platform_version.start_with? '6.1'
      'win7'
    elsif platform_version.start_with? '6.3'
      'win8'
    else
      'win10'
    end
  end

  def self.cafe_archive(runtime_identifier, version)
    "cafe-#{runtime_identifier}-x64-#{version}.zip"
  end
end
