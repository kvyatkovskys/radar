//
//  ListImagesViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 03/03/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher
import Lightbox

final class ListImagesViewController: UIViewController {
    var pageImages: PageImages?
    var controller: DetailPlaceViewController?
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.itemSize = CGSize(width: 80.0, height: 80.0)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0)
        layout.minimumLineSpacing = 2.0
        
        let collection = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        collectionView.snp.remakeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        updateViewConstraints()
        collectionView.register(ListImagesCollectionViewCell.self, forCellWithReuseIdentifier: ListImagesCollectionViewCell.cellIdentifier)
    }
    
    func reloadedData(pageImages: PageImages?, controller: DetailPlaceViewController?) {
        self.pageImages = pageImages
        self.controller = controller
        collectionView.reloadData()
    }
}

extension ListImagesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageImages?.previews.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListImagesCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? ListImagesCollectionViewCell ?? ListImagesCollectionViewCell()
        
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.kf.setImage(with: pageImages?.previews[indexPath.row],
                                   placeholder: nil,
                                   options: pageImages?.kingfisherOptions,
                                   progressBlock: nil,
                                   completionHandler: nil)
        return cell
    }
}

extension ListImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let lightbox = LightboxController(images: pageImages?.images.map({ LightboxImage(imageURL: URL(string: $0.source)!) }) ?? [],
                                          startIndex: indexPath.row)
        lightbox.dynamicBackground = true
        controller?.present(lightbox, animated: true, completion: nil)
    }
}
