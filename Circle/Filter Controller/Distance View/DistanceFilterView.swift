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
    let nearMe = PublishSubject<Bool>()
    
    fileprivate let filterDistance = FilterDistanceViewModel()
    
    fileprivate lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 500.0
        slider.maximumValue = 5000.0
        slider.tintColor = UIColor.sliderColor
        slider.isContinuous = true
        slider.setValue(Float(filterDistance.defaultDistance), animated: true)
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
        label.text = NSLocalizedString("minDistance", comment: "Text for filter of minimal distance")
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16.0)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    fileprivate lazy var swicthButton: UISwitch = {
        let swicth = UISwitch()
        swicth.setOn(filterDistance.searchForMinDistance, animated: false)
        swicth.onTintColor = .sliderColor
        swicth.tintColor = .lightGray
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
            make.right.equalTo(swicthButton.snp.left).offset(-10.0)
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
            .map({ value in
                let valueConverted = Int(value).formattedWithSeparator
                let localized = String.localizedStringWithFormat(
                    NSLocalizedString("%@ meters", comment: "Label for changing the values of the slider"), valueConverted
                )
                return localized
            })
            .distinctUntilChanged()
            .bind(to: titleDistance.rx.text)
            .disposed(by: disposeBag)
        
        slider.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [unowned self] (_) in
                self.sliderDistance.onNext(Double(self.slider.value).roundTo(places: 4))
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
        
        swicthButton.rx.value
            .bind(to: nearMe)
            .disposed(by: disposeBag)
        
        swicthButton.rx.value
            .map({ !$0 })
            .bind(to: slider.rx.isEnabled)
            .disposed(by: disposeBag)
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
