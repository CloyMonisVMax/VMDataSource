Pod::Spec.new do |s|
  s.name             = 'VMDataSource'
  s.version          = '0.0.2'
  s.summary          = 'A short summary of VMDataSource.'
  s.description      = 'A short description of VMDataSource.'
  s.homepage         = 'https://github.com/CloyMonisVMax/VMDataSource'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cloy Vserv' => 'cloy.m@vserv.com' }
  s.source           = { :git => 'https://github.com/CloyMonisVMax/VMDataSource.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_version = '5'
  s.source_files = 'VMDataSource/Classes/**/*'
  s.resources = "VMDataSource/Assets/Marvel.xcdatamodeld"
  
end

