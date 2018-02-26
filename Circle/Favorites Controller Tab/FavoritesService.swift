//
//  FavoritesService.swift
//  Circle
//
//  Created by Kviatkovskii on 01/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift
import Unbox
import FBSDKPlacesKit

struct FavoritesService {
    fileprivate let placeManager = FBSDKPlacesManager()
    fileprivate var setting = PlaceSetting()
    
    func loadInfoPlace(id: Int) -> Observable<PlaceModel> {
        var fields = setting.fields
        if let index = fields.index(where: { $0 == FBSDKPlacesResponseKeyMatchedCategories }) {
            fields.remove(at: index)
        }
        
        let request = placeManager.placeInfoRequest(forPlaceID: "\(id)", fields: fields)
        
        return Observable.create({ (observable) in
            _ = request.start(completionHandler: { (_, result, error) in
                guard error == nil else {
                    observable.on(.error(error!))
                    return
                }

                if let data = result as? [String: Any], let model: PlaceModel = try? unbox(dictionary: data) {
                    observable.on(.next(model))
                }
            })
            return Disposables.create()
        })
    }
}
