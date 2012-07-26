#
# Be sure to run `pod spec lint CSMapper.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "CSMapper"
  s.version      = "0.0.1"
  s.summary      = "CSMapper helps mapping arbitrary dictionaries to objects."
  s.homepage     = "https://github.com/marcammann/CSMapper"

  s.license      = 'MIT'
  s.author       = { "Marc Ammann" => "marc@codesofa.com" }
  s.source       = { :git => "https://github.com/marcammann/CSMapper.git", :tag => "0.0.1" }
  s.platform     = :ios
  s.source_files = '*.{h,m}'
  s.requires_arc = true
end
