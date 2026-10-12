# Uncomment the next line to define a global platform for your project
 platform :ios, '18.0'

target 'VideoSDKRTC_Example' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VideoSDKRTC_Example
  # VideoSDKRTC 4.x is added with Swift Package Manager (videosdk-rtc-ios-spm), not CocoaPods
  pod 'MessageKit'
  pod 'IQKeyboardManagerSwift'

end

# VideoSDKRTC 4.x requires iOS 18.0, and the pods' own targets (12.0 / 13.0) are below what Xcode supports
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
    end
  end
end
