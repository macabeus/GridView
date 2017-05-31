workspace './GridView.xcworkspace'

target 'GridView' do
  project 'GridView/GridView.xcodeproj'
  platform :tvos

  use_frameworks!

  # Pods for GridView

    target 'GridViewTests' do
        pod 'Quick'
        pod 'Nimble'
    end
end

target 'Example' do
  project 'Example-tvOS/Example.xcodeproj'
  platform :tvos, "10.2"

  use_frameworks!

  # Pods for Example
  pod 'GridView', :path => '.'
end
