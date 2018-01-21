//
//  FriendsModel.swift
//  Circle
//
//  Created by Kviatkovskii on 21/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import Unbox

struct FriendsModel {
    let data: [FriendModel]
    let next: URL?
}

extension FriendsModel: Unboxable {
    init(unboxer: Unboxer) throws {
        self.data = try unboxer.unbox(key: "data")
        let paging: [String: Any]? = unboxer.unbox(keyPath: "paging")
        self.next = paging != nil ? URL(string: paging!["next"] as? String ?? "") : nil
    }
}

struct FriendModel {
    let name: String?
    let picture: URL?
}

extension FriendModel: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = unboxer.unbox(key: "name")
        let data: [String: Any]? = unboxer.unbox(keyPath: "picture.data")
        self.picture = data != nil ? URL(string: data!["url"] as? String ?? "") : nil
    }
}
