Pod::Spec.new do |spec|
  spec.name         = "NetworkCompose"
  spec.version      = "0.0.1"
  spec.summary      = "NetworkCompose module"
  
  spec.description  = <<-DESC
                      A swift module supporting connecting to dynamic services.
                      DESC
  
  spec.homepage     = "https://github.com/harryngict/NetworkCompose"
  spec.source       = { :git => "git@github.com:harryngict/NetworkCompose.git", :tag => "#{spec.version}" }
  spec.authors      = { "Hoang Nguyen" => "harryngict@gmail.com" }
  spec.license      = { :type => "MIT", :text => "Copyright (c) 2023" }
  spec.swift_version = '5.0'
  spec.platform     = :ios, "12.0"
  spec.requires_arc = true
  spec.static_framework = true
  
  spec.subspec 'Core' do |core_spec|
    core_spec.source_files  = "NetworkCompose/Core/**/*.{swift}"
    core_spec.framework = "Foundation", "Network"
  end
  
  spec.subspec 'CoreMocks' do |core_mock_spec|
    core_mock_spec.dependency   "NetworkCompose/Core"
    core_mock_spec.source_files  = "NetworkCompose/CoreMocks/**/*.{swift}"
  end
  
  spec.subspec 'Queue' do |queue_spec|
    queue_spec.dependency   "NetworkCompose/Core"
    queue_spec.source_files  = "NetworkCompose/Queue/**/*.{swift}"
  end
  
  spec.subspec 'QueueMocks' do |queue_mock_spec|
    queue_mock_spec.dependency   "NetworkCompose/Core"
    queue_mock_spec.dependency   "NetworkCompose/Queue"
    queue_mock_spec.source_files  = "NetworkCompose/QueueMocks/**/*.{swift}"
  end
  
  spec.default_subspec = "Core"
end
