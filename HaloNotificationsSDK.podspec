Pod::Spec.new do |spec|
  spec.name             = 'HaloNotificationsSDK'
  spec.module_name      = 'HaloNotifications'
  spec.version          = '2.3.4'
  spec.summary          = 'HALO Notifications iOS SDK'
  spec.homepage         = 'https://mobgen.github.io/halo-documentation/ios_home.html'
  spec.license          = 'Apache License, Version 2.0'
  spec.author           = { 'Borja Santos-Diez' => 'borja.santos@mobgen.com' }
  spec.source           = { :git => 'https://github.com/mobgen/halo-notifications-ios.git', :tag => '2.3.4' }
  spec.source_files     = 'Source/**/*.swift'

  spec.platforms        = { :ios => '8.0' }
  spec.requires_arc     = true
  spec.ios.framework    = 'UserNotifications'

  spec.dependency 'HaloSDK'
  spec.dependency 'Firebase'

end
