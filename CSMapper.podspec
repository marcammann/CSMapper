Pod::Spec.new do |s|
  s.name         = "CSMapper"
  s.version      = "0.0.4"
  s.summary      = "CSMapper helps mapping arbitrary dictionaries to objects."
  s.homepage     = "https://github.com/marcammann/CSMapper"

  s.license      = 'Apache 2'
  s.author       = { "Marc Ammann" => "marc@codesofa.com" }
  s.source       = { :git => "https://github.com/marcammann/CSMapper.git", :tag => "0.0.3" }
  s.platform     = :ios
  s.source_files = "Classes"
  s.requires_arc = true
end
