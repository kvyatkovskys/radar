//
//  ListRestaurantViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 27/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListRestaurantViewController: UIViewController {    
    fileprivate var services: [RestaurantServiceType?]
    fileprivate var specialties: [RestaurantSpecialityType?]
    fileprivate var color: UIColor?
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0)
        layout.minimumLineSpacing = 5.0
        
        let collection = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        collectionView.snp.remakeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    init(service: RestaurantService?, speciality: RestaurantSpeciality?) {
        self.services = service?.services ?? []
        self.specialties = speciality?.specialties ?? []
        self.color = service == nil ? speciality?.color : service?.color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        updateViewConstraints()
        collectionView.register(ListRestaurantCollectionViewCell.self, forCellWithReuseIdentifier: ListRestaurantCollectionViewCell.cellIdentifier)
    }
    
    func reloadedData(service: RestaurantService?, speciality: RestaurantSpeciality?) {
        services = service?.services ?? []
        specialties = speciality?.specialties ?? []
        color = service == nil ? speciality?.color : service?.color
        collectionView.reloadData()
    }
}

extension ListRestaurantViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.isEmpty ? specialties.count : services.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListRestaurantCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? ListRestaurantCollectionViewCell ?? ListRestaurantCollectionViewCell()
        
        cell.color = color
        
        guard services.isEmpty else {
            cell.service = services[indexPath.row]
            return cell
        }
        
        cell.speciality = specialties[indexPath.row]
        return cell
    }
}

extension ListRestaurantViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard services.isEmpty else {
            return CGSize(width: services[indexPath.row]?.width ?? 70.0, height: 44.0)
        }
        return CGSize(width: specialties[indexPath.row]?.width ?? 70.0, height: 44.0)
    }
}
