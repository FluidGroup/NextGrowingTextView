Pod::Spec.new do |s|
  s.name             = "NextGrowingTextView"
  s.version          = "1.4.0"
  s.summary          = "The next in the generations of 'growing textviews' optimized for iOS 8 and above."
  s.homepage         = "https://github.com/muukii/NextGrowingTextView"
  s.license          = 'MIT'
  s.author           = { "muukii" => "muukii.app@gmail.com" }
  s.source           = { :git => "https://github.com/muukii/NextGrowingTextView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/muukii0803'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'NextGrowingTextView/**/*.swift'
end
