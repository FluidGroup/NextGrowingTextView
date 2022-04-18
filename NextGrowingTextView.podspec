Pod::Spec.new do |s|
  s.name             = "NextGrowingTextView"
  s.version          = "2.2.0"
  s.summary          = "The next in the generations of 'growing textviews' optimized for iOS 9 and above."
  s.homepage         = "https://github.com/muukii/NextGrowingTextView"
  s.license          = 'MIT'
  s.author           = { "muukii" => "muukii.app@gmail.com" }
  s.source           = { :git => "https://github.com/muukii/NextGrowingTextView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/muukii_app'

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.swift_version = "5.5"

  s.source_files = 'NextGrowingTextView/**/*.swift'
end
