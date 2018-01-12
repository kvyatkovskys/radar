//
//  RatingPlacesView.swift
//  Circle
//
//  Created by Kviatkovskii on 12/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class RatingPlacesView: UIView {
    fileprivate let upButton: UIButton = {
        let button = UIButton()
        let arrowImage = UIImage(named: "ic_arrow_up")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(arrowImage, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    fileprivate let downButton: UIButton = {
        let button = UIButton()
        let arrowImage = UIImage(named: "ic_arrow_down")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(arrowImage, for: .normal)
        button.tintColor = .black
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
