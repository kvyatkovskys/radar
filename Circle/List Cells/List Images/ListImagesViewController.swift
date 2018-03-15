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
import RxSwift

final class ListImagesViewController: UIViewController, LightboxControllerPageDelegate {
    fileprivate var pageImages: PageImages?
    fileprivate var controller: DetailPlaceViewController?
    fileprivate var viewModel: DetailPlaceViewModel?
    fileprivate let disposeBag = DisposeBag()
    fileprivate var lightBox = LightboxController()
    fileprivate let loadMore = PublishSubject<URL>()
    
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
        
        loadMore.flatMap { [unowned self] (url) -> Observable<PageImages> in
            return self.viewModel!.loadMorePhotos(url: url)
            }
            .observeOn(MainScheduler.instance)
            .asObservable()
            .subscribe(onNext: { [unowned self] (model) in
                self.pageImages?.images += model.images
                self.pageImages?.previews += model.previews
                self.pageImages?.nextImages = model.nextImages
                self.collectionView.reloadData()
                self.lightBox.images = self.pageImages?.images.map({ LightboxImage(imageURL: URL(string: $0.source)!) }) ?? []
                }, onError: { (error) in
                    print(error)
            }).disposed(by: disposeBag)
    }
    
    func reloadedData(pageImages: PageImages?, controller: DetailPlaceViewController?, viewModel: DetailPlaceViewModel?) {
        self.pageImages = pageImages
        self.controller = controller
        self.viewModel = viewModel
        collectionView.reloadData()
        lightBox = LightboxController(images: pageImages?.images.map({ LightboxImage(imageURL: URL(string: $0.source)!) }) ?? [],
                                      startIndex: 0)
    }
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        if page == (pageImages?.images.count ?? 0) - 5, let url = URL(string: pageImages?.nextImages ?? "") {
            loadMore.onNext(url)
        }
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
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row == (pageImages?.images.count ?? 0) - 5 && indexPath.section == 0, let url = URL(string: pageImages?.nextImages ?? "") else {
            return
        }
        loadMore.onNext(url)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lightBox = LightboxController(images: pageImages?.images.map({ LightboxImage(imageURL: URL(string: $0.source)!) }) ?? [],
                                      startIndex: indexPath.row)
        lightBox.pageDelegate = self
        lightBox.dynamicBackground = true
        controller?.present(lightBox, animated: true, completion: nil)
    }
}
