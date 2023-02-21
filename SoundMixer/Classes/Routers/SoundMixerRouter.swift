//
//  SoundMixerRouter.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-13.
//

import Foundation
import UIKit


protocol SoundMixerPresenterToRouter: AnyObject {
    var viewController: SoundMixerViewController? { get }
}


class SoundMixerRouter {
    
    let window = UIWindow()

    private var presenters = [SoundMixerPresenterToRouter]()
    
    static let shared: SoundMixerRouter = {
        let sharedInstance = SoundMixerRouter()
        return sharedInstance
    }()
    
    @MainActor func setupAndShowRootVC() {
        let initialVC = HomeViewController()
        window.rootViewController = initialVC
        window.makeKeyAndVisible()
    }
    
    @MainActor func presentSoundsVC() -> SoundMixerPresenter {
        let soundsVC = SoundMixerViewController()
        let soundsInteractor = SoundMixerInteractor()
        let soundMixerPresenter = SoundMixerPresenter(vc: soundsVC, interactor: soundsInteractor)
        presenters.append(soundMixerPresenter)
        let nc = UINavigationController(rootViewController: soundsVC)
        nc.modalPresentationStyle = .fullScreen
        getRootVC()?.present(nc, animated: true)
        return soundMixerPresenter
    }
    
    @MainActor func dismissSoundsVC(animated: Bool, completion: ((_ successful: Bool) -> Void)? = nil) {
        guard let topMostVC = getRootVC()?.topMostVC() as? SoundMixerViewController else {
            completion?(false)
            return
        }

        presenters.removeAll { presenter in
            return presenter.viewController == topMostVC
        }
        topMostVC.popOrDismiss(animated) {
            completion?(true)
        }
    }
}

// MARK: Private methods

extension SoundMixerRouter {
    
    private func getRootVC() -> BaseViewController? {
        return window.rootViewController as? BaseViewController
    }
}
