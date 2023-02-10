//
//  BaseViewController.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-03.
//

import Foundation
import UIKit


class BaseViewController: UIViewController {
    
    func popOrDismiss(_ animated: Bool, completion: (() -> Void)? = nil) {
        if let navigationController = navigationController {
            if let index = navigationController.viewControllers.firstIndex(of: self), index > 0 {
                navigationController.popToViewController(self, animated: false)
                navigationController.popViewController(animated: animated)
            } else {
                navigationController.dismiss(animated: animated)
            }
            completion?()
        } else {
            self.dismiss(animated: animated, completion: completion)
        }
    }
}
