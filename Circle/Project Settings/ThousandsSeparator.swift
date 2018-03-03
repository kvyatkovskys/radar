//
//  ThousandsSeparator.swift
//  Circle
//
//  Created by Kviatkovskii on 03/03/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 2
        formatter.maximumIntegerDigits = 4
        return formatter
    }()
}

extension Int {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}
