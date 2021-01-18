Pod::Spec.new do |s|

  s.name         = "LiveSDKResurrected"
  s.version      = "5.7.0"
  s.summary      = "Client libraries for calling Live Services from iOS apps"
  s.description  = <<-DESC
                   Client libraries for calling the Live Services from iOS apps. Provides
                   easy access to OneDrive, Outlook.com, and Microsoft Account authentication
                   from your iOS application.
                   DESC
  s.homepage     = "http://dev.onedrive.com"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author             = { "onedriveapi" => "onedriveapi@microsoft.com" }
  s.social_media_url   = "http://twitter.com/onedrivedev"

  s.module_name  = "LiveSDK"
  s.ios.deployment_target = "11.0"
  s.compiler_flags = "-DNS_BLOCK_ASSERTIONS=1"

  s.source       = { :git => "https://github.com/spamdrain/LiveSDK-for-iOS.git",
                     :tag => "#{s.version}" }

  s.source_files  = "src/LiveSDK/**/*.{h,m}"
  s.exclude_files = "src/UnitTests/**", "Examples/**"
  s.public_header_files = "src/LiveSDK/Library/Public/*.h"

  s.framework = "WebKit"
  s.resources = "src/LiveSDK/Library/Internal/Resources/*.png",
  				"src/LiveSDK/Library/Internal/*.xib"
  s.requires_arc = false

end
