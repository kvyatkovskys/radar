//
//  String+Extension.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

extension String {
    var capitalizedFirstSymbol: String {
        return self.replacingCharacters(in: startIndex...startIndex, with: String(self[startIndex]).capitalized)
    }
    
    var htmlToString: String? {
        do {
            guard let data = data(using: String.Encoding.utf8) else { return nil }
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil).string
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
    func width(font: UIFont, height: CGFloat) -> CGFloat {
        return self.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: height),
                                 options: .usesLineFragmentOrigin,
                                 attributes: [.font: font],
                                 context: nil).width
    }
    
    func height(font: UIFont, width: CGFloat) -> CGFloat {
        return self.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                 options: .usesLineFragmentOrigin,
                                 attributes: [.font: font],
                                 context: nil).height
    }
}
