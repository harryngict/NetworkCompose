Pod::Spec.new do |spec|
spec.name         = "NetworkCompose"
  spec.version      = "0.1.7"
  spec.summary      = "NetworkCompose is a versatile library simplifying powerful networking tasks."
  spec.description  = <<-DESC
                      NetworkCompose simplifies and enhances network-related tasks by providing a flexible and intuitive composition of network components. From seamless integration of URLSession to advanced features like SSL pinning, mocking, metric reporting, and smart retry mechanisms.
                      DESC
  
  spec.homepage     = "https://github.com/harryngict/NetworkCompose"
  spec.source       = { :git => "git@github.com:harryngict/NetworkCompose.git", :tag => "#{spec.version}" }
  spec.authors      = { "Hoang Nguyezn" => "harryngict@gmail.com" }
  spec.license      = { :type => "MIT", :text => "Copyright (c) 2023" }
  spec.swift_version = '5.0'
  spec.platform     = :ios, "14.0"
  spec.requires_arc = true
  spec.static_framework = false
  spec.source          = { path: '.' }
  spec.source_files    = 'src/*.swift'
  spec.frameworks = ['Foundation']
end
