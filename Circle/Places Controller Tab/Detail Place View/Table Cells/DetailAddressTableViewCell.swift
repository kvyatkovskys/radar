//
//  DetailAddressTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import MapKit

fileprivate extension UIColor {
    static var shadowGray: UIColor {
        return UIColor(withHex: 0xecf0f1, alpha: 1.0)
    }
    
    static var mainColor: UIColor {
        return UIColor(withHex: 0xf82462, alpha: 1.0)
    }
}

final class DetailAddressTableViewCell: UITableViewCell {
    static var cellIdentifier = "DetailAddressTableViewCell"
    
    fileprivate let addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15.0)
        return label
    }()
    
    fileprivate lazy var mapButton: UIButton = {
        let button = UIButton()
        button.setTitle(" Map", for: .normal)
        button.setImage(UIImage(named: "ic_map")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.mainColor
        button.titleLabel?.font = .boldSystemFont(ofSize: 17.0)
        button.setTitleColor(UIColor.mainColor, for: .normal)
        button.backgroundColor = UIColor.shadowGray
        button.layer.cornerRadius = 5.0
        button.addTarget(self, action: #selector(openMap), for: .touchUpInside)
        return button
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        addressLabel.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10.0)
            make.right.equalToSuperview().offset(-10.0)
            make.bottom.equalTo(mapButton.snp.top).offset(-10.0)
        }
        
        mapButton.snp.remakeConstraints { (make) in
            make.height.equalTo(30.0)
            make.centerX.equalToSuperview()
            make.width.equalTo(120.0)
            make.bottom.equalToSuperview().offset(-10.0)
        }
    }
    
    var address: String? {
        didSet {
            addressLabel.text = address
        }
    }
    
    var location: LocationPlace?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(addressLabel)
        addSubview(mapButton)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openMap() {
        let latitude: CLLocationDegrees = location?.latitude ?? 0
        let longitude: CLLocationDegrees = location?.longitude ?? 0
        
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                       MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = address
        mapItem.openInMaps(launchOptions: options)
    }
}
