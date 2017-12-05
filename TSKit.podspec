#
# Be sure to run `pod lib lint TSKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TSKit'
  s.version          = '1.2'
  s.summary          = 'A framework for commonly used functions'
  s.homepage         = 'https://github.com/TenjiuinSaki/TSKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zhang Yufei' => '498172524@qq.com' }
  s.source           = { :git => 'https://github.com/TenjiuinSaki/TSKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://github.com/TenjiuinSaki'
  s.ios.deployment_target = "8.0"
  s.source_files = 'TSKit/**/*'
end
