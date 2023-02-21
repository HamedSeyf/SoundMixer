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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        SoundMixerRouter.shared.setupAndShowRootVC()
        return true
    }
}
