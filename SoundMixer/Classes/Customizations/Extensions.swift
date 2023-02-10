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
    
    func topMostVC() -> UIViewController? {
        if let presentedViewController = presentedViewController {
            return presentedViewController.topMostVC()
        }
        return self
    }
}

extension Object {
    
    enum JSONParseError: Error {
        case fileNotFound
        case decodingFailed
    }
    
    static func loadModelsFromJSON<T>(_ fileName: String) async -> Result<[T]?, JSONParseError> where T: Decodable {
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

    static var shared: Realm? = {
        do {
            return try Realm()
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
