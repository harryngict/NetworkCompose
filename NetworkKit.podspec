Pod::Spec.new do |spec|
  
  spec.name         = "NetworkKit"
  spec.version      = "0.0.1"
  spec.summary      = "NetworkKit module"
  
  spec.description  = <<-DESC
                      A swift module support connect to dynamic services.
                      DESC
  
  spec.homepage     = "https://github.com/harryngict/NetworkKit"
  spec.source       = { :git => "git@github.com:harryngict/NetworkKit.git", :tag => "#{spec.version}" }
  spec.authors      = { "Hoang Nguyen" => "harryngict@gmail.com" }
  spec.license      = { :type => "MIT", :text => "Copyright (c) 2023" }
  spec.swift_version = '5.0'
  spec.platform     = :ios, "12.0"
  spec.requires_arc = true
  spec.static_framework = true
  
  spec.subspec 'Core' do |core_spec|
    core_spec.source_files  = "NetworkKit/Core/**/*.{swift}"
    core_spec.framework = "Foundation", "Network"
  end
  
  spec.subspec 'CoreMocks' do |core_mock_spec|
    core_mock_spec.dependency   "NetworkKit/Core"
    core_mock_spec.source_files  = "NetworkKit/CoreMocks/**/*.{swift}"
  end
  
  spec.subspec 'NetworkQueue' do |network_queue_spec|
    network_queue_spec.dependency   "NetworkKit/Core"
    network_queue_spec.source_files  = "NetworkKit/NetworkQueue/**/*.{swift}"
  end
  
  spec.subspec 'NetworkQueueMocks' do |network_queue_mock_spec|
    network_queue_mock_spec.dependency   "NetworkKit/Core"
    network_queue_mock_spec.dependency   "NetworkKit/NetworkQueue"
    network_queue_mock_spec.source_files  = "NetworkKit/NetworkQueueMocks/**/*.{swift}"
  end
end
