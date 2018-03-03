//
//  DetailImagesTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 03/03/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher

typealias PageImages = (images: [Images], previews: [URL?], nextImages: String, kingfisherOptions: KingfisherOptionsInfo)

final class DetailImagesTableViewCell: UITableViewCell {
    static let cellIdentifier = "DetailImagesTableViewCell"
    
    fileprivate lazy var listImagesViewController: ListImagesViewController = {
        let list = ListImagesViewController()
        list.view.frame = contentView.frame
        contentView.addSubview(list.view)
        return list
    }()
    
    var pageImages: PageImages? {
        didSet {
            listImagesViewController.reloadedData(pageImages: pageImages)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
