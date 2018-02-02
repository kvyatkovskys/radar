//
//  Error+Extension.swift
//  Circle
//
//  Created by Kviatkovskii on 20/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

enum RequestErrorType: Int {
    case noConnection = -1009
    case unauthorized = 401
    case internalServerError = 500
    case timeOut = 504
    case custom = 0
    case other = -1
    case tokenExpires = 1
    case empty = 2
    case emptyUrl = 3
    case tokenEmpty = 4
    
    init(error: NSError) {
        if let type = RequestErrorType(rawValue: error.code) {
            self = type
        } else {
            self = .other
        }
    }
}

extension NSError {
    var errorType: RequestErrorType {
        return RequestErrorType(error: self)
    }
    
    static var commonDomain: String {
        return "com.kviatkovskii"
    }
    
    convenience init(type: RequestErrorType, info: String) {
        self.init(domain: NSError.commonDomain, code: type.rawValue, userInfo: ["UserInfo": info])
    }
}
