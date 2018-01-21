//
//  OpenGraphService.swift
//  Circle
//
//  Created by Kviatkovskii on 21/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift

struct OpenGraphService {
    func loadListLikes(id: String) {
        let grapPath = "\(id)?fields=friends_who_like,friends_tagged_at,music_listen_friends,id,video_watch_friends"
        let request = FBSDKGraphRequest(graphPath: grapPath, parameters: [:], httpMethod: "GET")
        _ = request?.start(completionHandler: { (_, result, error) in
            print(result as Any, error as Any)
        })
    }
}
