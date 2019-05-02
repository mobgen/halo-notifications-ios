Pod::Spec.new do |spec|
  spec.name             = 'HaloNotificationsSDK'
  spec.module_name      = 'HaloNotifications'
  spec.version          = '2.6.0'
  spec.summary          = 'HALO Notifications iOS SDK'
  spec.homepage         = 'https://mobgen.github.io/halo-documentation/ios_home.html'
  spec.license          = 'Apache License, Version 2.0'
  spec.author           = { 'Juan Soilan Lopez' => 'juan.soilan@mobgen.com' }
  spec.source           = { :http => 'https://github.com/mobgen/halo-notifications-ios/archive/2.6.0.zip' }
  spec.source_files     = 'Source/*.swift', 'Libraries/*.swift', 'Source/*.h', 'Source/*.m', 'Users/juan/Documents/Mobgen/Repos/halo-notifications-ios/Carthage/Build/iOS/*.frameworks'




  spec.platforms        = { :ios => '8.0' }
  spec.requires_arc     = true
  spec.ios.framework    = 'UserNotifications'
  spec.ios.vendored_frameworks = 'halo-notifications-ios-2.6.0/Frameworks/Firebase/**/*.framework'
  spec.ios.vendored_libraries = 

  #spec.source_files     = 'halo-notifications-ios-2.6.0/Source/**/*.swift'
  spec.resources        = ['halo-notifications-ios-2.6.0/Sounds/*'] 

  spec.dependency 'HaloSDK' , '~> 2.6.0'

  spec.static_framework = true

  spec.frameworks = 'MapKit', 'Foundation', 'SystemConfiguration', 'CoreText', 'QuartzCore', 'Security', 'UIKit', 'Foundation', 'CoreGraphics','CoreTelephony', 'FirebaseCore', 'FirebaseRemoteConfig', 'FirebaseInstanceID', 'FirebaseAnalytics', 'FirebaseABTesting', 'FirebaseCoreDiagnostics', 'FirebaseNanoPB'
  spec.libraries = 'c++', 'sqlite3', 'z'


  #spec.libraries = 'c++', 'sqlite3', 'z'
  # spec.vendored_framework = 'Firebase'
  spec.dependency 'Firebase'
  spec.dependency 'Firebase/Core'
  spec.dependency 'Firebase/RemoteConfig'
  #  spec.dependency 'GoogleToolboxForMac'
  #  spec.dependency 'nanopb'
  #  spec.dependency 'Protobuf'
  #  spec.dependency 'FirebaseInstanceID'
  #  spec.dependency 'FirebaseAnalytics'
  #  spec.dependency 'FirebaseABTesting'


  spec.pod_target_xcconfig = {
      'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/Firebase $(PODS_ROOT)/FirebaseCore/Frameworks $(PODS_ROOT)/FirebaseRemoteConfig/Frameworks $(PODS_ROOT)/FirebaseInstanceID/Frameworks $(PODS_ROOT)/FirebaseAnalytics/Frameworks $(PODS_ROOT)/FirebaseABTesting/Frameworks'
  }

  spec.pod_target_xcconfig = {
      'OTHER_LDFLAGS' => '$(inherited) -ObjC'
  }

end
