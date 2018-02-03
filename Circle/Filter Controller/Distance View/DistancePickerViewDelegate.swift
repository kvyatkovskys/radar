//
//  DistancePickerViewDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 05/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift

final class DistancePickerViewDelegate: NSObject {
    let selectValue = PublishSubject<Double>()
    fileprivate let items: [FilterDistanceModel]
    
    init(_ pickerView: UIPickerView, _ items: [FilterDistanceModel]) {
        self.items = items
        super.init()
        pickerView.delegate = self
    }
}

extension DistancePickerViewDelegate: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectValue.onNext(items[row].value)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].title
    }

}