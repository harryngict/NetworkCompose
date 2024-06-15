Pod::Spec.new do |spec|
  spec.name         = "NetworkComposeMock"
  spec.version      = "0.0.1"
  spec.summary      = "NetworkComposeMock"
  spec.description  = <<-DESC
                      The "NetworkComposeMock" to mock NetworkCompose using in unit tests
                      DESC
  spec.homepage     = "https://github.com/harryngict/NetworkCompose"
  spec.authors      = { "Hoang Nguyen" => "harryngict@gmail.com" }
  spec.license      = { :type => "MIT", :text => "Copyright © 2024" }
  spec.swift_version = '5.0'
  spec.platform     = :ios, "14.0"
  spec.requires_arc = true
  spec.static_framework = false
  spec.source          = { path: '.' }
  spec.source_files = 'src/**/*.{swift,h}'
  spec.frameworks = ['Foundation']
  spec.dependency 'NetworkCompose'
end
