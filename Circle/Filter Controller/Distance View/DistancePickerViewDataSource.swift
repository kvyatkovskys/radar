//
//  DistancePickerViewDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 05/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DistancePickerViewDataSource: NSObject {
    fileprivate let items: [FilterDistanceModel]
    
    init(_ pickerView: UIPickerView, _ viewModel: FilterDistanceViewModel) {
        self.items = viewModel.items
        super.init()
        pickerView.dataSource = self
        
        if let index = items.index(where: { $0.value == viewModel.defaultDistance }) {
            pickerView.selectRow(index, inComponent: 0, animated: true)
        }
    }
}

extension DistancePickerViewDataSource: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
}