//
//  FilterPlacesViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 03/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

protocol FilterPlacesDelegate: class {
    func selectDistance(value: Double)
}

final class FilterPlacesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    typealias Dependecies = HasFilterPlacesViewModel & HasFilterPlacesDelegate
    
    fileprivate let viewModelDistance: FilterDistanceViewModel
    fileprivate weak var delegate: FilterPlacesDelegate?
    fileprivate let segmentedControl: UISegmentedControl = {
        let segmented = UISegmentedControl(items: ["Distance"])
        segmented.frame = CGRect(x: 0.0, y: 20.0, width: 40.0, height: 22.0)
        segmented.selectedSegmentIndex = 0
        return segmented
    }()
    
    fileprivate lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let segmentedControl = UIBarButtonItem(customView: self.segmentedControl)
        
        toolBar.setItems([segmentedControl], animated: true)
        
        return toolBar
    }()
    
    fileprivate lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.addSubview(self.toolBar)
        return picker
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        pickerView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        toolBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
        }
    }
    
    init(_ dependecies: Dependecies) {
        self.viewModelDistance = dependecies.viewModel
        self.delegate = dependecies.delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(pickerView)
        updateViewConstraints()
        
        if let index = viewModelDistance.items.index(where: { $0.value == viewModelDistance.defaultDistance }) {
            pickerView.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModelDistance.items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModelDistance.items[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserDefaults.standard.set(viewModelDistance.items[row].value, forKey: "FilterDistance")
        delegate?.selectDistance(value: viewModelDistance.items[row].value)
    }
}
