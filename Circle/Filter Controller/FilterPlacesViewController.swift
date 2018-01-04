//
//  FilterPlacesViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 03/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift

protocol FilterPlacesDelegate: class {
    func selectDistance(value: Double)
}

final class FilterPlacesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    typealias Dependecies = HasFilterPlacesViewModel & HasFilterPlacesDelegate
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModelDistance: FilterDistanceViewModel
    fileprivate let viewModel: FilterViewModel
    fileprivate weak var delegate: FilterPlacesDelegate?
    
    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let segmented = UISegmentedControl(items: viewModel.items.map({ $0.title }))
        segmented.selectedSegmentIndex = 0
        return segmented
    }()
    
    fileprivate lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10.0)
            make.left.right.equalToSuperview().inset(15.0)
        }
        
        pickerView.snp.makeConstraints { (make) in
            make.top.equalTo(segmentedControl.snp.bottom).offset(5.0)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    init(_ dependecies: Dependecies) {
        self.viewModel = dependecies.viewModel
        self.viewModelDistance = dependecies.viewModelDistance
        self.delegate = dependecies.delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(segmentedControl)
        view.addSubview(pickerView)
        updateViewConstraints()
        
        if let index = viewModelDistance.items.index(where: { $0.value == viewModelDistance.defaultDistance }) {
            pickerView.selectRow(index, inComponent: 0, animated: true)
        }
        
        segmentedControl.rx.selectedSegmentIndex.subscribe(onNext: { (index) in
            print(index)
        }, onError: { (error) in
            print(error)
        }).disposed(by: disposeBag)
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
