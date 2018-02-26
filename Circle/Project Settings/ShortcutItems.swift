//
//  ShortcutItems.swift
//  Circle
//
//  Created by Kviatkovskii on 25/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

enum TypeShortcut: String {
    case searchTab, favoritesTab, settingsTab
    
    var tabIndex: Int {
        switch self {
        case .searchTab:
            return 1
        case .favoritesTab:
            return 2
        case .settingsTab:
            return 3
        }
    }
}
