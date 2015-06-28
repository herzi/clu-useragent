#
# Be sure to run `pod lib lint CLUUserAgent.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CLUUserAgent"
  s.version          = "0.1.0"
  s.summary          = "Consistent User-Agent Strings for Cocoa"
  s.description      = <<-DESC
                       Provide consistent User-Agent strings for Cocoa apps:

                       * Reproduce the default User-Agent for iOS
                       * Provide ways to customize it.
                       DESC
  s.homepage         = "https://github.com/herzi/clu-useragent"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Sven Herzberg" => "sven.herzberg@cluepunk.com" }
  s.source           = { :git => "https://github.com/herzi/clu-useragent.git", :tag => 'v' + s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CLUUserAgent' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
