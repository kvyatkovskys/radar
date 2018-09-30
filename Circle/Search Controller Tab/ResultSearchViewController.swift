//
//  ResultSearchViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 02/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import Swinject

final class ResultSearchViewController: UIViewController {
    
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    fileprivate var dataSource: [PlaceModel] = []
    fileprivate let disposeBag = DisposeBag()
    let selectResult = PublishSubject<PlaceModel>()
    let tableView = KSTableView()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    init(_ container: Container) {
        self.kingfisherOptions = container.resolve(KingfisherOptionsInfo.self)!
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        updateViewConstraints()
        
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.cellIndetifier)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(PlaceModel.self)
            .subscribe(onNext: { [unowned self] (place) in
                self.selectResult.onNext(place)
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}

extension ResultSearchViewController: UITableViewDelegate {    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightTableCell
    }
}
