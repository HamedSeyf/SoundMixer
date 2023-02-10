//
//  AppDelegate.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-03.
//

import Foundation
import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let homeVC = HomeViewController()
        window = UIWindow()
        window!.rootViewController = homeVC
        window!.makeKeyAndVisible()
        return true
    }
}
