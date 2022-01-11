#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'smartlook'
  s.version          = '0.0.5'
  s.summary          = 'Smartlook'
  s.description      = <<-DESC
Smartlook iOS SDK plugin.
                       DESC
  s.homepage         = 'https://smartlook.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Smartlook' => 'support@smartlook.com' }
  
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/SmartlookPlugin.h'

  s.vendored_frameworks = "Smartlook.xcframework"

  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

