//
//  AppDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 08/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import YandexMobileMetrica

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        migrations(schema: 9)
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
        setupNavigationBar()
        initialViewController()
        YMMYandexMetrica.activate(withApiKey: yandexKey)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        checkAuthNotification(application)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                     open: url,
                                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String ?? "",
                                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    fileprivate func checkAuthNotification(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .denied, .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { [unowned self] (accept, _) in
                    if !accept {
                        let alertController = UIAlertController(title: NSLocalizedString("noticeDisabled",
                                                                                         comment: "title for alert when disabled notice"),
                                                                message: NSLocalizedString("allowNotice", comment: "text for allow notice"),
                                                                preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "button for alert notification"),
                                                         style: .cancel,
                                                         handler: nil)
                        alertController.addAction(cancelAction)
                        
                        let openAction = UIAlertAction(title: NSLocalizedString("openSettings", comment: "button for open settings"),
                                                       style: .default) { _ in
                            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                        alertController.addAction(openAction)
                        
                        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                    }
                }
            case .authorized:
                DispatchQueue.main.async {
                    guard application.applicationIconBadgeNumber > 0 else { return }
                    application.applicationIconBadgeNumber = 0
                }
            }
        }
    }
    
    fileprivate func initialViewController(index: Int = 0) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        
        let locationService = LocationService()
        let router = Router()
        window?.rootViewController = router.showMainTabController(locationService, startTab: index)
    }
    
    fileprivate func setupNavigationBar() {
        let navBarAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().titleTextAttributes = navBarAttributes
        UINavigationBar.appearance().barTintColor = UIColor.navBarColor
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    fileprivate func migrations(schema: UInt64) {
        let config = Realm.Configuration(schemaVersion: schema, migrationBlock: { _, oldSchemaVersion in
            if oldSchemaVersion < schema { }
        })
        
        Realm.Configuration.defaultConfiguration = config
        do {
            _ = try Realm()
        } catch {
            print(error)
        }
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let type = TypeShortcut(rawValue: shortcutItem.type) else {
            completionHandler(false)
            return
        }
        initialViewController(index: type.tabIndex)
        completionHandler(true)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        checkAuthNotification(application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
