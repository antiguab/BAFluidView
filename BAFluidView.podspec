Pod::Spec.new do |s|
  s.name             = "BAFluidView"
  s.version          = "0.2.3"
  s.summary          = "UIView that simulates a 2D view of a fluid in motion"
  s.description      = <<-DESC
                        This view and it's layer create a 2D fluid animation that can be used to simulate a filling effect.
                        more info at: [https://github.com/antiguab/BAFluidView](https://github.com/antiguab/BAFluidView)
                       DESC
  s.homepage         = "https://github.com/antiguab/BAFluidView"
  s.screenshots     = "https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/screenshot1.png?raw=true", "https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/screenshot2.png?raw=true","https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/screenshot3.png?raw=true","https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/screenshot4.png?raw=true"
  s.license          = 'MIT'
  s.author           = { "Bryan Antigua" => "antigua.b@gmail.com" }
  s.source           = { :git => "https://github.com/antiguab/BAFluidView.git", :tag => s.version.to_s }
  s.platform     = :ios
  s.requires_arc = true
  s.social_media_url = 'https://twitter.com/brantigua'

  s.source_files = 'Pod/Classes'

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
