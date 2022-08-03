#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'motion'
  s.version          = '0.0.1'
  s.summary          = 'Motion'
  s.description      = <<-DESC
  A fancy widget that applies a gyroscope or hover based motion effect to its child.
                       DESC
  s.homepage         = 'https://github.com/mrcendre/motion'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'mrcendre' => 'guillaume@cendre.me' }
  s.source           = { :http => 'https://github.com/mrcendre/motion' }
  s.documentation_url = 'https://pub.dev/packages/motion'
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.platform = :ios, '8.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
