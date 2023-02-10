//
//  SoundMixerView.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-03.
//

import Foundation
import UIKit


protocol SoundMixerViewAnimationProtocol: AnyObject {
    func animatePlayerView(onScreen: Bool)
}


class SoundMixerView: UIView {
    
    private var backgroundView: BackgroundView!
    private var soundPlayerView: SoundPlayerView!
    private var soundCollectionView: SoundCollectionView!
    
    private var playerIsOnScreen: Bool = true
    
    private static let SoundPlayerHeight: CGFloat = 80.0
    private static let SoundPlayerOffset: CGFloat = 20.0
    private static let SoundPlayerMaxWidth: CGFloat = 400.0
    private static let SoundCollectionViewVerticalOffset: CGFloat = 20.0
    
    required init() {
        super.init(frame: .zero)
        
        backgroundView = BackgroundView()
        addSubview(backgroundView)
        
        soundCollectionView = SoundCollectionView()
        addSubview(soundCollectionView)
        
        soundPlayerView = SoundPlayerView()
        addSubview(soundPlayerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(allSounds: [SoundModelPresenter]?, soundPlayerPresenter: SoundPlayerViewDelegate) {
        DispatchQueue.dispatchMainIfNeeded { [weak self] in
            self?.soundCollectionView.updateUI(allSounds: allSounds)
            self?.soundPlayerView.updateUI(presenter: soundPlayerPresenter)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        let playerWidth = min(frame.width - 2.0 * SoundMixerView.SoundPlayerOffset, SoundMixerView.SoundPlayerMaxWidth)
        soundPlayerView.frame = CGRect(x: round(0.5 * (frame.width - playerWidth)), y: getPlayerViewMinY(onScreen: playerIsOnScreen), width: playerWidth, height: SoundMixerView.SoundPlayerHeight)
        
        soundCollectionView.frame = CGRect(x: 0, y: SoundMixerView.SoundCollectionViewVerticalOffset, width: frame.width, height: getPlayerViewMinY(onScreen: true) - SoundMixerView.SoundCollectionViewVerticalOffset)
    }
}

// MARK: SoundMixerViewAnimationProtocol implementations

extension SoundMixerView: SoundMixerViewAnimationProtocol {
    
    func animatePlayerView(onScreen: Bool) {
        playerIsOnScreen = onScreen
        
        startPlayerAnimation()
    }
}

// MARK: Private methods

extension SoundMixerView {
    
    private func startPlayerAnimation() {
        DispatchQueue.dispatchMainIfNeeded { [weak self] in
            guard let originalFrame = self?.soundPlayerView.frame else { return }
            guard let targetY: CGFloat = self?.getPlayerViewMinY(onScreen: self?.playerIsOnScreen ?? false) else { return }
            
            let targetFrame = CGRect(x: originalFrame.minX, y: targetY, width: originalFrame.width, height: originalFrame.height)
            UIView.animate(withDuration: 0.8, animations: { [weak self] in
                self?.soundPlayerView.frame = targetFrame
            })
        }
    }
    
    private func getPlayerViewMinY(onScreen: Bool) -> CGFloat {
        return onScreen ? (frame.height - SoundMixerView.SoundPlayerHeight - SoundMixerView.SoundPlayerOffset) : frame.height
    }
}
