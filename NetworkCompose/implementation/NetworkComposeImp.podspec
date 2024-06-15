Pod::Spec.new do |spec|
  spec.name         = "NetworkComposeImp"
  spec.version      = "0.1.7"
  spec.summary      = "NetworkComposeImp"
  spec.description  = <<-DESC
                      The "NetworkComposeImp" to implement NetworkCompose
                      DESC
  spec.homepage     = "https://github.com/harryngict/NetworkCompose"
  spec.authors      = { "Hoang Nguyen" => "harryngict@gmail.com" }
  spec.license      = { :type => "MIT", :text => "Copyright © 2023" }
  spec.swift_version = '5.0'
  spec.platform     = :ios, "14.0"
  spec.requires_arc = true
  spec.static_framework = false
  spec.source          = { path: '.' }
  spec.source_files = 'src/**/*.{swift,h}'
  spec.frameworks = ['Foundation']
  spec.dependency 'NetworkCompose'
  
  spec.test_spec 'UnitTests' do |test_spec|
     test_spec.source_files = 'Tests/**/*.{swift,h}'
     test_spec.requires_app_host = true
     test_spec.frameworks = ['XCTest']
     test_spec.dependency 'NetworkComposeMock'
   end
end
