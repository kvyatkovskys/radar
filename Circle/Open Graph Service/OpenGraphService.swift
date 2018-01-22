//
//  OpenGraphService.swift
//  Circle
//
//  Created by Kviatkovskii on 21/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift
import Unbox

struct OpenGraphService {
    // пока не работает, нужно поменять урл, когда будет больше пользователей,
    // потому что facebook отдаёт список друзей только, когда юзер установит приложение
    // пока просто получаю список всех друзей, чтобы обработать модельку
    func loadListLikes(id: String) -> Observable<FriendsModel> {
        let grapPath = "/me/taggable_friends"
        let request = FBSDKGraphRequest(graphPath: grapPath, parameters: ["fields": "id,name,picture.width(200).height(200)"], httpMethod: "GET")
        
        return Observable.create({ (observable) in
            _ = request?.start(completionHandler: { (_, result, error) in
                guard error == nil else {
                    observable.on(.error(error!))
                    return
                }
                
                if let data = result as? [String: Any], let model: FriendsModel = try? unbox(dictionary: data) {
                    observable.on(.next(model))
                }
            })
            return Disposables.create()
        })
    }
}
