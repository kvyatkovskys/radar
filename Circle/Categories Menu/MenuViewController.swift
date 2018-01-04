//
//  MenuViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 01.06.17.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher
import SnapKit

enum TypeOpened: Int {
    case swiped, moved
}

protocol MenuViewControllerDelegate: class {
    func selectCategoryInMenu(category: Categories)
}

final class MenuViewController: UIViewController, MenuTableDelegate, UIGestureRecognizerDelegate {
    fileprivate let mainController: UIViewController
    fileprivate weak var delegate: MenuViewControllerDelegate?
    fileprivate let menuViewModel: MenuViewModel
    
    fileprivate var tableViewDataSource: MenuTableViewDataSource?
    // swiftlint:disable weak_delegate
    fileprivate var tableViewDelegate: MenuTableViewDelegate?
    fileprivate let disposeBag = DisposeBag()
    fileprivate var tableWidth: Constraint?
    fileprivate var tableLeft: Constraint?
    fileprivate var tableBottom: Constraint?
    fileprivate var viewRight: Constraint?
    fileprivate var viewBottom: Constraint?
    fileprivate let options: KingfisherOptionsInfo?
    fileprivate let typeOpened: TypeOpened
    fileprivate var isOpenMenu: Bool = false
    
    fileprivate let statusHeaderView: UIView = {
        let view = UIView()
        view.alpha = 1
        return view
    }()
    
    fileprivate let backGroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 1
        return view
    }()

    let tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView(frame: CGRect.zero)
        return table
    }()
    
    fileprivate func updateConstraint() {
    
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24.0)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        backGroundView.snp.remakeConstraints { (make) in
            make.top.left.equalToSuperview()
            viewRight = make.right.equalToSuperview().constraint
            viewBottom = make.bottom.equalToSuperview().constraint
        }
        
        super.updateViewConstraints()
    }
    
    init(mainController: UIViewController,
         menuDelegate: MenuViewControllerDelegate,
         menuViewModel: MenuViewModel,
         options: KingfisherOptionsInfo?,
         typeOpened: TypeOpened = .swiped) {
        self.mainController = mainController
        self.delegate = menuDelegate
        self.menuViewModel = menuViewModel
        self.options = options
        self.typeOpened = typeOpened
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        view.addSubview(backGroundView)
        statusHeaderView.addSubview(tableView)
       
        updateConstraint()
        
        // настраиваем таблицу для меню
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: MenuTableViewCell.cellIdentifier)
        tableViewDataSource = MenuTableViewDataSource(tableView: tableView, viewModel: menuViewModel)
        tableViewDelegate = MenuTableViewDelegate(tableView: tableView, viewModel: menuViewModel, menuTableDelegate: self)
        
        // подписываемся на жесты, чтобы закрыть меню и убрать затемнение
        let tapClose = UITapGestureRecognizer(target: self, action: #selector(closeLeftMenu))
        tapClose.numberOfTapsRequired = 1
        backGroundView.addGestureRecognizer(tapClose)
        
        // подписываемся на свайп в меню левый и закрываем менюху
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(closeMenu))
        tableView.addGestureRecognizer(gesture)
        tableView.isUserInteractionEnabled = true
        gesture.delegate = self
 
        guard DeviceType.IS_IPAD_PRO || DeviceType.IS_IPAD || DeviceType.IS_IPAD_10_5 else {
            switch typeOpened {
            case .swiped:
                // свайп от края экрана
                let screenPanEdge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleLeftEdgeSwipe))
                screenPanEdge.edges = UIRectEdge.left
                mainController.view.addGestureRecognizer(screenPanEdge)
            case .moved:
                // двигаем пальцем по экрану и тащим меню
                let gesture = UIPanGestureRecognizer(target: self, action: #selector(openMenu))
                mainController.view.addGestureRecognizer(gesture)
                mainController.view.isUserInteractionEnabled = true
                gesture.delegate = self
            }
            
            return
        }
    }
    
    // вызываем боковую менюшку по свайпу от края экрана
    @objc func handleLeftEdgeSwipe(sender: UIGestureRecognizer) {
        mainController.view.endEditing(true)
        if sender.state == UIGestureRecognizerState.began {
            openLeftMenu()
        }
    }
    
    // тапаем на пункт меню
    func chooseCategory(category: Categories) {
        delegate?.selectCategoryInMenu(category: category)
    }
    
    // показываем менюшку
    func openLeftMenu() {
        isOpenMenu = true
        // скрываем поповеры, любые
        presentedViewController?.dismiss(animated: true, completion: nil)
        
        if let win: UIWindow = UIApplication.shared.delegate?.window as? UIWindow {
            view.frame = win.frame
            self.willMove(toParentViewController: self)
            win.addSubview(self.view)
            self.navigationController?.addChildViewController(self)
            self.didMove(toParentViewController: self)
            
            // добавляем менюшку на вьюху
            self.tableLeft?.update(offset: 0)
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.view.layoutIfNeeded()
                self.backGroundView.alpha = 0.2
            }
        }
    }
    
    // скрываем меню
    @objc func closeLeftMenu() {
        isOpenMenu = false
        tableLeft?.update(offset: offsetForDevice())
        
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            self.view.layoutIfNeeded()
            self.backGroundView.alpha = 0.0
            }, completion: { [unowned self] _ in
                self.willMove(toParentViewController: nil)
                self.removeFromParentViewController()
                self.view.removeFromSuperview()
        })
    }
    
    @objc fileprivate func openMenu(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        let velocity = gestureRecognizer.velocity(in: view)

        if !isOpenMenu {
            guard translation.x >= 0 else { return }
        }
        
        switch gestureRecognizer.state {
        case .began, .changed:
            guard fabs(velocity.y) < fabs(velocity.x) else {
                if isOpenMenu {
                    gestureRecognizer.cancel()
                    moveRightMenu()
                }
                return
            }
            
            guard -75...0 ~= Double(statusHeaderView.center.x) else {
                if let win: UIWindow = UIApplication.shared.delegate?.window as? UIWindow {
                    // добавляем менюшку на вьюху
                    if !isOpenMenu {
                        // скрываем поповеры, любые
                        presentedViewController?.dismiss(animated: true, completion: nil)
                        isOpenMenu = true
                        
                        view.frame = win.frame
                        willMove(toParentViewController: self)
                        win.addSubview(view)
                        navigationController?.addChildViewController(self)
                        didMove(toParentViewController: self)
                        
                        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
                            self.backGroundView.alpha = 0.2
                        })
                    }
                    guard velocity.x < 1000 else {
                        gestureRecognizer.cancel()
                        moveRightMenu()
                        return
                    }
                    
                    let x = (tableView.frame.origin.x + translation.x)
                    tableLeft?.update(offset: x)
                    gestureRecognizer.setTranslation(CGPoint.zero, in: view)
                    view.layoutIfNeeded()
                }
                return
            }
            
            gestureRecognizer.cancel()
            moveRightMenu()
        case .ended, .failed:
            guard -300 ... 0 ~= Double(tableView.center.x) else { return }
            moveLeftMenu()
        default:
            break
        }
    }
    
    @objc fileprivate func closeMenu(gestureRecognizer: UIPanGestureRecognizer) {
        guard isOpenMenu else { return }
        let translation = gestureRecognizer.translation(in: view)
        let velocity = gestureRecognizer.velocity(in: view)
        
        switch gestureRecognizer.state {
        case .began, .changed:
            guard translation.x <= 0 else {
                if tableView.frame.origin.x <= 0 {
                    moveRightMenu()
                    tableView.isScrollEnabled = true
                }
                return
            }
            
            guard fabs(velocity.y) < fabs(velocity.x) else { return }
            
            tableView.isScrollEnabled = false
            
            guard 95...180 ~= Double(tableView.center.x) else {
                moveLeftMenu()
                return
            }
            guard velocity.x < 1000 else {
                moveLeftMenu()
                return
            }
            
            let x = tableView.frame.origin.x + translation.x
            tableLeft?.update(offset: x)
            gestureRecognizer.setTranslation(CGPoint.zero, in: view)
            view.layoutIfNeeded()
        default:
            guard 0...180 ~= Double(tableView.center.x) else { return }
            tableView.isScrollEnabled = true
            gestureRecognizer.cancel()
            moveRightMenu()
        }
    }
    
    fileprivate func moveRightMenu() {
        tableLeft?.update(offset: 0)
        
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func moveLeftMenu() {
        isOpenMenu = false
        tableLeft?.update(offset: offsetForDevice())
        tableView.isScrollEnabled = true
        
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            self.view.layoutIfNeeded()
            self.backGroundView.alpha = 0.0
            }, completion: { [unowned self] _ in
                self.willMove(toParentViewController: nil)
                self.removeFromParentViewController()
                self.view.removeFromSuperview()
        })
    }
    
    fileprivate func getCurrentWidthMenu() -> CGFloat {
        guard DeviceType.IS_IPAD || DeviceType.IS_IPAD_PRO || DeviceType.IS_IPAD_10_5 else {
            return ScreenSize.SCREEN_WIDTH - 40.0
        }
        
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .portraitUpsideDown:
            return ScreenSize.SCREEN_MAX_LENGTH / 2
        case .landscapeLeft, .landscapeRight:
            return ScreenSize.SCREEN_MIN_LENGTH / 2
        default:
            return ScreenSize.SCREEN_MAX_LENGTH
        }
    }
    
    fileprivate func offsetForDevice() -> CGFloat {
        if DeviceType.IS_IPAD || DeviceType.IS_IPAD_PRO || DeviceType.IS_IPAD_10_5 {
            return -getCurrentWidthMenu()
        } else {
            return -ScreenSize.SCREEN_WIDTH + 40.0
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return isOpenMenu
    }
}

extension UIGestureRecognizer {
    func cancel() {
        isEnabled = false
        isEnabled = true
    }
}
