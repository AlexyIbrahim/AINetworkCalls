Pod::Spec.new do |s|
  s.name             = 'AINetworkCalls'
  s.version          = '1.2.5'
  s.summary          = 'Networking library'

  s.homepage         = 'https://gitlab.com/alexyib/ainetworkcalls.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Alexy Ibrahim' => 'alexy.ib@gmail.com' }
  s.source           = { :git => 'https://gitlab.com/alexyib/ainetworkcalls.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/AINetworkCalls/**/*'
end