Pod::Spec.new do |spec|
  spec.name         = "NetworkCompose"
  spec.version      = "0.0.2"
  spec.summary      = "NetworkCompose is a versatile library simplifying powerful networking tasks."
  spec.description  = <<-DESC
                      NetworkCompose simplifies and enhances network-related tasks by providing a flexible and intuitive composition of network components. From seamless integration of URLSession to advanced features like SSL pinning, mocking, metric reporting, and smart retry mechanisms.
                      DESC
  
  spec.homepage     = "https://github.com/harryngict/NetworkCompose"
  spec.source       = { :git => "git@github.com:harryngict/NetworkCompose.git", :tag => "#{spec.version}" }
  spec.authors      = { "Hoang Nguyen" => "harryngict@gmail.com" }
  spec.license      = { :type => "MIT", :text => "Copyright (c) 2023" }
  spec.swift_version = '5.0'
  spec.platform     = :ios, "12.0"
  spec.requires_arc = true
  spec.static_framework = true
  spec.source_files  = "Sources/NetworkCompose/**/**/*.{swift}"
end
