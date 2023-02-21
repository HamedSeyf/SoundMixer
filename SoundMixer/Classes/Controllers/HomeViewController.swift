//
//  HomeViewController.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-03.
//

import Foundation
import UIKit


class HomeViewController: BaseViewController {
    
    private var homeView: HomeView!
}

// MARK: UIViewController lifecycle

extension HomeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeView = HomeView(yesTapCallback: { [weak self] in
            // There are some other VCs blocking this VC (possibly another instance of SoundsViewController) which means we need to ignore this tap
            guard self == self?.topMostVC() else { return }
            
            _ = SoundMixerRouter.shared.presentSoundsVC()
        }, noTapCallback: { [weak self] in
            let alert = UIAlertController(title: nil, message: "We wish we could terminate the app for you.\nUnfortunately this is against Apple's submission acceptance criteria!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self?.present(alert, animated: true)
        })
        view.addSubview(homeView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        homeView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }
}
