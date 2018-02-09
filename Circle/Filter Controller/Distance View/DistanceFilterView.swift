//
//  DistanceFilterView.swift
//  Circle
//
//  Created by Kviatkovskii on 09/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift

fileprivate extension UIColor {
    static var sliderColor: UIColor {
        return UIColor(withHex: 0xf82462, alpha: 1.0)
    }
}

final class DistanceFilterView: UIView {
    fileprivate let disposeBag = DisposeBag()
    let sliderDistance = PublishSubject<Double>()
    
    fileprivate lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 500.0
        slider.maximumValue = 5000.0
        slider.tintColor = UIColor.sliderColor
        slider.isContinuous = true
        slider.setValue(Float(FilterDistanceViewModel().defaultDistance), animated: true)
        return slider
    }()
    
    fileprivate lazy var titleDistance: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: 15.0)
        return label
    }()
    
    fileprivate lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    fileprivate lazy var titleMinDistance: UILabel = {
        let label = UILabel()
        label.text = "Near me"
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16.0)
        return label
    }()
    
    fileprivate lazy var swicthButton: UISwitch = {
        let swicth = UISwitch()
        swicth.setOn(false, animated: true)
        return swicth
    }()
    
    func setConstraints() {
        slider.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15.0)
            make.left.right.equalToSuperview().inset(12.0)
        }
        
        titleDistance.snp.makeConstraints { (make) in
            make.top.equalTo(slider.snp.bottom).offset(10.0)
            make.left.right.equalTo(slider)
            make.height.equalTo(15.0)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(titleDistance.snp.bottom).offset(15.0)
            make.left.right.equalToSuperview().inset(11.0)
            make.height.equalTo(0.5)
        }
        
        titleMinDistance.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(25.0)
            make.left.equalToSuperview().offset(12.0)
            make.right.equalTo(swicthButton.snp.left).inset(10.0)
            make.height.equalTo(25.0)
        }
        
        swicthButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleMinDistance)
            make.right.equalToSuperview().inset(12.0)
            make.width.equalTo(51.0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        addSubview(titleDistance)
        addSubview(slider)
        addSubview(lineView)
        addSubview(titleMinDistance)
        addSubview(swicthButton)
        
        setConstraints()
        
        slider.rx.value
            .map({ "\(Int($0)) meters" })
            .distinctUntilChanged()
            .bind(to: titleDistance.rx.text)
            .disposed(by: disposeBag)
        
        slider.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [unowned self] (_) in
                self.sliderDistance.onNext(Double(self.slider.value).roundTo(places: 4))
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
