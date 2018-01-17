//
//  DeatilPhoneWebsiteTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import SnapKit

fileprivate extension UIColor {
    static var blueButton: UIColor {
        return UIColor(withHex: 0x3498db, alpha: 1.0)
    }
}

final class DeatilPhoneWebsiteTableViewCell: UITableViewCell {
    static let cellIdentifier = "DeatilPhoneWebsiteTableViewCell"
    
    fileprivate var centerXPhone: Constraint?
    fileprivate var centerXSite: Constraint?
    
    fileprivate lazy var phoneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Call", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15.0)
        button.backgroundColor = UIColor.blueButton
        button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(callPhone), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var websiteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Website", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15.0)
        button.backgroundColor = UIColor.blueButton
        button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(openSite), for: .touchUpInside)
        return button
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        phoneButton.snp.makeConstraints { (make) in
            make.width.equalTo(100.0)
            make.top.bottom.equalToSuperview().inset(15.0)
            centerXPhone = make.centerX.equalTo(self.snp.centerX).offset(-80.0).constraint
        }
        
        websiteButton.snp.makeConstraints { (make) in
            make.width.equalTo(100.0)
            make.top.bottom.equalToSuperview().inset(15.0)
            centerXSite = make.centerX.equalTo(self.snp.centerX).offset(80.0).constraint
        }
    }
    
    var phone: Int? {
        didSet {
            guard phone != nil else {
                phoneButton.isHidden = true
                centerXSite?.update(offset: 0)
                layoutIfNeeded()
                return
            }
        }
    }
    
    var site: String? {
        didSet {
            guard site != nil else {
                websiteButton.isHidden = true
                centerXPhone?.update(offset: 0)
                layoutIfNeeded()
                return
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(phoneButton)
        addSubview(websiteButton)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func callPhone() {
        if let url = URL(string: "tel://\(phone ?? 0)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func openSite() {
        if let url = URL(string: "\(site ?? "")"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
