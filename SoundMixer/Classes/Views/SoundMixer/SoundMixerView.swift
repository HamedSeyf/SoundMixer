//
//  SoundMixerView.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-03.
//

import Foundation
import UIKit


protocol SoundMixerViewDelegate: SoundPlayerViewDelegate, SoundViewCellDelegate {
}


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
    
    required init(delegate: SoundMixerViewDelegate) {
        super.init(frame: .zero)
        
        backgroundView = BackgroundView()
        addSubview(backgroundView)
        
        soundCollectionView = SoundCollectionView(delegate: delegate)
        addSubview(soundCollectionView)
        
        soundPlayerView = SoundPlayerView(delegate: delegate)
        addSubview(soundPlayerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor func updateUI(allSounds: [any SoundModelToView], playbackIsPaused: Bool) {
        let hasPlayingSongs: Bool = allSounds.first(where: { SoundModelToView in
            return SoundModelToView.isPlaying
        }) != nil
    
        soundCollectionView.updateUI(allSounds: allSounds)
        soundPlayerView.updateUI(playbackIsPaused: playbackIsPaused)
        animatePlayerView(onScreen: hasPlayingSongs)
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
    
    @MainActor private func startPlayerAnimation() {
        let originalFrame = soundPlayerView.frame
        let targetY: CGFloat = getPlayerViewMinY(onScreen: playerIsOnScreen)
        
        let targetFrame = CGRect(x: originalFrame.minX, y: targetY, width: originalFrame.width, height: originalFrame.height)
        UIView.animate(withDuration: 0.8, animations: { [weak self] in
            self?.soundPlayerView.frame = targetFrame
        })
    }
    
    private func getPlayerViewMinY(onScreen: Bool) -> CGFloat {
        return onScreen ? (frame.height - SoundMixerView.SoundPlayerHeight - SoundMixerView.SoundPlayerOffset) : frame.height
    }
}
