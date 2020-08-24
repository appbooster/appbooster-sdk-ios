#
# Be sure to run `pod lib lint AppboosterSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AppboosterSDK'
  s.version          = '0.1.10'
  s.summary          = 'Mobile framework for Appbooster platform.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Mobile framework for Appbooster platform. Now includes working with A/B-tests'

  s.homepage         = 'https://github.com/appbooster/appbooster-sdk-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'VladimirKhuraskin' => 'khuraskin.dev@gmail.com' }
  s.source           = { :git => 'https://github.com/appbooster/appbooster-sdk-ios.git', :tag => s.version }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'AppboosterSDK/Classes/*', 'AppboosterSDK/Classes/**/*'
  
  s.resource_bundles = {
    'AppboosterSDK' => ['AppboosterSDK/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.swift_version = "5.0"

end
