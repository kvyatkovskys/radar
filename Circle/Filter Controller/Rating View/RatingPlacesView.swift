//
//  RatingPlacesView.swift
//  Circle
//
//  Created by Kviatkovskii on 12/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift

enum TypeRating: Int {
    case none, up, down
}

final class RatingPlacesView: UIView {
    let chooseRating = PublishSubject<TypeRating>()
    
    fileprivate lazy var upButton: UIButton = {
        let button = UIButton()
        let arrowImage = UIImage(named: "ic_arrow_up")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(arrowImage, for: .normal)
        button.tintColor = .lightGray
        button.tag = 1
        button.addTarget(self, action: #selector(tapUpRating(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var downButton: UIButton = {
        let button = UIButton()
        let arrowImage = UIImage(named: "ic_arrow_down")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(arrowImage, for: .normal)
        button.tintColor = .lightGray
        button.tag = 2
        button.addTarget(self, action: #selector(tapDownRating(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    fileprivate func setConstraints() {
        lineView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(35.0)
            make.width.equalTo(0.5)
            make.centerX.equalToSuperview()
        }
        
        upButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(35.0)
            make.left.equalToSuperview()
            make.right.equalTo(lineView.snp.left)
        }
        
        downButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(35.0)
            make.right.equalToSuperview()
            make.left.equalTo(lineView.snp.right)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(lineView)
        addSubview(upButton)
        addSubview(downButton)
        
        setConstraints()
        
        do {
            let realm = try Realm()
            let results = realm.objects(FilterSelectedRating.self).first
            if let type = results {
                let rating = TypeRating(rawValue: type.rating)
                switch rating {
                case .up?:
                    upButton.tintColor = .black
                    upButton.isSelected = true
                case .down?:
                    downButton.tintColor = .black
                    downButton.isSelected = true
                case .some(.none):
                    break
                case .none:
                    break
                }
            }
        } catch {
            print(error)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapUpRating(_ sender: UIButton) {
        downButton.tintColor = .lightGray
        downButton.isSelected = false
        sender.isSelected = !sender.isSelected

        guard sender.isSelected else {
            sender.tintColor = .lightGray
            chooseRating.onNext(TypeRating.none)
            return
        }
        
        sender.tintColor = .black
        chooseRating.onNext(TypeRating(rawValue: sender.tag)!)
    }
    
    @objc func tapDownRating(_ sender: UIButton) {
        upButton.tintColor = .lightGray
        upButton.isSelected = false
        sender.isSelected = !sender.isSelected
        
        guard sender.isSelected else {
            sender.tintColor = .lightGray
            chooseRating.onNext(TypeRating.none)
            return
        }
        
        sender.tintColor = .black
        chooseRating.onNext(TypeRating(rawValue: sender.tag)!)
    }
}
