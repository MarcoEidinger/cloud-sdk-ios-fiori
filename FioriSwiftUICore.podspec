Pod::Spec.new do |s|
  s.name             = 'FioriSwiftUICore'
  s.version          = '1.0.0'
  s.summary          = 'FioriSwiftUICore Lib'

  s.description      = <<-DESC
A/B testing is a Firebase service that lets you run experiments across users of
your mobile apps. It lets you learn how well one or more changes to
your app work with a smaller set of users before you roll out changes to all
users. You can run experiments to find the most effective ways to use
Firebase Cloud Messaging and Firebase Remote Config in your app.
                       DESC

  s.homepage         = 'https://firebase.google.com'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.authors          = 'SAP'

  s.source           = {
    :git => 'https://github.com/MarcoEidinger/cloud-sdk-ios-fiori.git',
    :tag => '3.3.3'
  }

  s.social_media_url = 'https://twitter.com/sapsdk'

  ios_deployment_target = '13.0'

  s.ios.deployment_target = ios_deployment_target

  s.cocoapods_version = '>= 1.4.0'
  s.prefix_header_file = false

  base_dir = "FioriSwiftUICore/Sources/"
  s.source_files = [
    base_dir + '**/*.[swift]',
  ]
  s.requires_arc = base_dir + '*.m'
end
