platform :ios, '10.0'

def pods
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SnapKit'
  pod 'Unbox'
  pod 'Kingfisher'
  pod 'RealmSwift'
  pod 'FBSDKCoreKit'  
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  pod 'FBSDKPlacesKit'
end

target 'Circle' do
  use_frameworks!
  pods

  target 'CircleTests' do
    inherit! :search_paths
    pods
  end
  
  target 'CircleUITests' do
      inherit! :search_paths
      pods
  end

end
