# react-native-dlna.podspec

require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-dlna"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-dlna
                   DESC
  s.homepage     = "https://github.com/472647301/react-native-dlna"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "秃尾巴的猫" => "472647301@qq.com" }
  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/472647301/react-native-dlna.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,cc,cpp,m,mm,swift}"
  s.requires_arc = true
  s.vendored_frameworks = 'Neptune.framework', 'Platinum.framework'
  # s.vendored_libraries = "ios/*.a"
  s.dependency "React"
  # ...
  # s.dependency "..."
end

