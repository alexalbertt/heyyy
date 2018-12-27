# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Crush' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Crush
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Core'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
pod 'SwiftKeychainWrapper'
pod 'MessageKit'
pod 'Alamofire'
pod 'JSQMessagesViewController'
pod 'SAConfettiView'
pod 'RevealingSplashView'
pod 'TextFieldEffects'
pod 'CropViewController'
pod 'PinCodeTextField'
pod 'SDWebImage'

post_install do |installer|
	installer.pods_project.build_configurations.each do |config|
		config.build_settings.delete('CODE_SIGNING_ALLOWED')
		config.build_settings.delete('CODE_SIGNING_REQUIRED')
	end
end
end
