Pod::Spec.new do |s|
  s.name         = "GridView"
  s.version      = "0.1.1"
  s.summary      = "Amazing grid view in your tvOS/iOS app"
  s.homepage     = "https://github.com/brunomacabeusbr/GridView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Bruno Macabeus" => "bruno.macabeus@gmail.com" }

  s.ios.deployment_target = "10.3"
  s.tvos.deployment_target = "10.2"

  s.source       = { :git => "https://github.com/brunomacabeusbr/GridView.git", :tag => s.version }
  s.source_files = "GridView/GridView/*.swift"

end
