//
//  AppDelegate.swift
//  MapDemo
//
//  Created by Milan on 07/10/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupNavigationBarApperance(navigationBar: UINavigationBar.appearance(), color: .clear)
        return true
    }

    func setupNavigationBarApperance(navigationBar: UINavigationBar, color: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)) {
        if #available(iOS 13.0, *) {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.label, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20.0)]
        } else {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20.0)]
        }
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = UIColor.red
        navigationBar.backgroundColor = color
        navigationBar.barTintColor = color
        navigationBar.isTranslucent = true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        PersistentStorage.shared.saveContext()
    }
    
}
