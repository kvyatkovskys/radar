//
//  AppDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 08/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import RealmSwift

// color for navigation bar
fileprivate extension UIColor {
    static var navBarColor: UIColor {
        return UIColor(withHex: 0x34495e, alpha: 1.0)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        migrations(schema: 2)
        setupNavigationBar()
        initialViewController()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                     open: url,
                                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String ?? "",
                                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    fileprivate func initialViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        
        let router = Router()
        window?.rootViewController = router.showMainTabController()
    }
    
    fileprivate func setupNavigationBar() {
        let navBarAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().titleTextAttributes = navBarAttributes
        UINavigationBar.appearance().barTintColor = UIColor.navBarColor
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    fileprivate func migrations(schema: UInt64) {
        let config = Realm.Configuration(
            schemaVersion: schema,
            migrationBlock: { _, oldSchemaVersion in
                if oldSchemaVersion < schema {
                    
                }
        })
        Realm.Configuration.defaultConfiguration = config
        
        do {
            _ = try Realm()
        } catch {
            print(error)
        }
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
