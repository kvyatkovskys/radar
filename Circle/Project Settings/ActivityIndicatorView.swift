//
//  ActivityIndicatorView.swift
//  Circle
//
//  Created by Kviatkovskii on 03/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

final class ActivityIndicatorView: UIView {
    fileprivate let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        indicator.color = UIColor.white
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .whiteLarge
        return indicator
    }()
    
    fileprivate lazy var activityView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.6
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    fileprivate let containerView: UIView
    
    override func updateConstraints() {
        super.updateConstraints()
        
        activityView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 80.0, height: 80.0))
        }
        
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    init(container: UIView) {
        self.containerView = container
        super.init(frame: container.bounds)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(activityView)
        activityView.addSubview(activityIndicator)
        
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showIndicator() {
        DispatchQueue.main.async { [unowned self] in
            self.alpha = 1.0
            self.activityIndicator.startAnimating()
            self.containerView.addSubview(self)
        }
    }
    
    func hideIndicator() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: 0.3, animations: {
                self.activityIndicator.stopAnimating()
                self.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }
}
