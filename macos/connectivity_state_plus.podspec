#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'connectivity_state_plus'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Connectivity'
  s.description      = <<-DESC
This plugin allows Flutter apps to discover network connectivity and configure themselves accordingly.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/leo1394/connectivity_state_plus/'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Community Team' => 'authors@fluttercommunity.dev' }
  s.source           = { :http => 'https://github.com/leo1394/connectivity_state_plus' }
  s.documentation_url = 'https://pub.dev/packages/connectivity_state_plus'
  s.source_files = 'connectivity_state_plus/Sources/connectivity_state_plus/**/*.swift'
  s.dependency 'FlutterMacOS'
  s.platform = :osx
  s.osx.deployment_target = '10.14'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'connectivity_state_plus_privacy' => ['connectivity_state_plus/Sources/connectivity_state_plus/PrivacyInfo.xcprivacy']}
end
