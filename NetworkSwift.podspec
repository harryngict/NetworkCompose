Pod::Spec.new do |spec|
  spec.name         = "NetworkSwift"
  spec.version      = "0.0.8"
  spec.summary      = "NetworkSwift module"
  
  spec.description  = <<-DESC
                      A swift module supporting connecting to dynamic services.
                      DESC
  
  spec.homepage     = "https://github.com/harryngict/NetworkSwift"
  spec.readme       = "https://github.com/harryngict/NetworkSwift/#{spec.version}/README.md"
  spec.source       = { :git => "git@github.com:harryngict/NetworkSwift.git", :tag => "#{spec.version}" }
  spec.authors      = { "Hoang Nguyen" => "harryngict@gmail.com" }
  spec.license      = { :type => "MIT", :text => "Copyright (c) 2023" }
  spec.swift_version = '5.0'
  spec.platform     = :ios, "12.0"
  spec.requires_arc = true
  spec.static_framework = true
  
  spec.subspec 'Core' do |core_spec|
    core_spec.source_files  = "NetworkSwift/Core/**/*.{swift}"
    core_spec.framework = "Foundation", "Network"
  end
  
  spec.subspec 'CoreMocks' do |core_mock_spec|
    core_mock_spec.dependency   "NetworkSwift/Core"
    core_mock_spec.source_files  = "NetworkSwift/CoreMocks/**/*.{swift}"
  end
  
  spec.subspec 'Queue' do |queue_spec|
    queue_spec.dependency   "NetworkSwift/Core"
    queue_spec.source_files  = "NetworkSwift/Queue/**/*.{swift}"
  end
  
  spec.subspec 'QueueMocks' do |queue_mock_spec|
    queue_mock_spec.dependency   "NetworkSwift/Core"
    queue_mock_spec.dependency   "NetworkSwift/Queue"
    queue_mock_spec.source_files  = "NetworkSwift/QueueMocks/**/*.{swift}"
  end
  
  spec.default_subspec = "Core"
end
