Pod::Spec.new do |spec|
  spec.name             = 'HaloNotificationsSDK'
  spec.module_name      = 'HaloNotifications'
  spec.version          = '2.2.0'
  spec.summary          = 'HALO Notifications iOS SDK'
  spec.homepage         = 'https://mobgen.github.io/halo-documentation/ios_home.html'
  spec.license          = 'Apache License, Version 2.0'
  spec.author           = { 'Borja Santos-Diez' => 'borja.santos@mobgen.com' }
  spec.source           = { :git => 'https://github.com/mobgen/halo-notifications-ios.git', :tag => '2.2.0' }

  spec.platforms        = { :ios => '8.0' }
  spec.requires_arc     = true

  spec.source_files     = 'Source/**/*.swift'
  spec.resources        = ['Sounds/*'] 
 
  spec.dependency 'HaloSDK'
  spec.dependency 'Firebase/Analytics'
  spec.dependency 'Firebase/Messaging'

end