//
//  Extensions.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-04.
//

import Foundation
import RealmSwift
import UIKit


extension UIViewController {
    
    @MainActor func topMostVC() -> UIViewController? {
        if let presentedViewController = presentedViewController {
            return presentedViewController.topMostVC()
        }
        if let ncTypedSelf = self as? UINavigationController, let topViewController = ncTypedSelf.topViewController {
            return topViewController.topMostVC()
        }
        return self
    }
    
    @MainActor func popOrDismiss(_ animated: Bool, completion: (() -> Void)? = nil) {
        if let navigationController = self.navigationController {
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
    
    @MainActor func showAlertWithOK(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}

extension Object {
    
    enum JSONParseError: Error, LocalizedError {
        case fileNotFound
        case decodingFailed
        
        public var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "File not found."
            case .decodingFailed:
                return "Decoding failed."
            }
        }
    }
    
    static func loadModelsFromJSON<T>(_ fileName: String) -> Result<[T], JSONParseError> where T: Decodable {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else { return .failure(.fileNotFound) }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let models = try decoder.decode([T].self, from: data)
            return .success(models)
        } catch {
            return .failure(.decodingFailed)
        }
    }
}

extension Realm {
    
    static let dispatchQueue = DispatchQueue(label: "\(Realm.self)Queue")

    static let shared: Realm? = {
        do {
            return try Realm(queue: dispatchQueue)
        } catch let e {
            fatalError("Realm could not start: " + e.localizedDescription)
        }
    }()
}

extension DispatchQueue {

    static func dispatchMainIfNeeded(_ closure: @escaping () -> Void) {
        guard self === DispatchQueue.main && Thread.isMainThread else {
            DispatchQueue.main.async(execute: closure)
            return
        }
        
        closure()
    }
}

extension UIColor {
    
    enum AppColors {
        case playerBackground
        case playerBorder
        case playerButton
        
        var color: UIColor {
            switch self {
            case .playerBackground:
                return UIColor(red: 0.239, green: 0.294, blue: 0.404, alpha: 0.85)
            case .playerBorder:
                return UIColor(red: 0.408, green: 0.478, blue: 0.533, alpha: 1.0)
            case .playerButton:
                return UIColor.white
            }
        }
    }
}
