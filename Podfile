platform :ios, '9.0'

def pods
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SnapKit'
  pod 'Unbox'
  pod 'RadarSDK'
end

target 'Circle' do
  use_frameworks!

  pods

  target 'CircleTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
