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
