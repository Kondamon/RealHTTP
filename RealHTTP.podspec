Pod::Spec.new do |s|
  s.name         = "RealHTTP"
  s.version      = "0.9.20"
  s.summary      = "HTTP client for Swift ages: data encoding/auto deserialization, network metrics, stub, combine and more"
  s.homepage     = "https://github.com/immobiliare/RealHTTP.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Immobiliarelabs" => "mobile@immobiliare.it" }
  s.social_media_url   = "https://twitter.com/immobiliarelabs"
  s.ios.deployment_target = '13.0'
  s.source           = {
    :git => 'https://github.com/immobiliare/RealHTTP.git',
    :tag => s.version.to_s
  }
  s.swift_versions = ['5.0', '5.1', '5.3', '5.4', '5.5']
  s.framework = 'Foundation'

  s.source_files = 'Sources/RealHTTP/**/*.swift'
end
