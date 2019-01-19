//
//  ListImagesCollectionViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 03/03/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

class ListImagesCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "ListImagesCollectionViewCell"
    
    var imageView: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .shadowGray
        return image
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        imageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
