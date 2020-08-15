#
# Be sure to run `pod lib lint MEFacebookAdapter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MEFacebookAdapter'
  s.version          = '0.1.1'
  s.summary          = 'A short description of MEFacebookAdapter.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "This is a Mobiexchanger's advertise adapter, and we use it as a module"

  s.homepage         = 'https://github.com/liusas/MEFacebookAdapter.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Liusas' => 'liufeng@mobiexchanger.com' }
  s.source           = { :git => 'https://github.com/liusas/MEFacebookAdapter.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.vendored_frameworks = ['MEFacebookAdapter/Classes/Framework/*']
  s.ios.deployment_target = '10.0'

  s.source_files = 'MEFacebookAdapter/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MEFacebookAdapter' => ['MEFacebookAdapter/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.dependency "MEAdvSDK", '~>0.1.5'
end
