Pod::Spec.new do |s|
  s.name             = "BAFluidView"
  s.version          = "0.1.0"
  s.summary          = "UIView that simulates a 2D view of a fluid in motion"
  s.description      = <<-DESC
                         UIView that simulates a 2D view of a fluid in motion - WIP
                       DESC
  s.homepage         = "https://github.com/antiguab/BAFluidView"
  # s.screenshots     = "", ""
  s.license          = 'MIT'
  s.author           = { "Bryan Antigua" => "antigua.b@gmail.com" }
  s.source           = { :git => "https://github.com/antiguab/BAFluidView.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'BAFluidView' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
