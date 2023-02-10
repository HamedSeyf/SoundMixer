//
//  SoundPlayerPresenter.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-05.
//

import Foundation


class SoundPlayerPresenter {
    
    typealias PlayPauseButtonTapCallback = (()->Void)
    typealias ClearButtonTapCallback = (()->Void)
    typealias IsPlayingQuery = (()->Bool)
    
    private var playPauseButtonTapCallback: PlayPauseButtonTapCallback?
    private var clearButtonTapCallback: ClearButtonTapCallback?
    private var isPlayingQuery: IsPlayingQuery?
    
    required init(playPauseButtonTapCallback: PlayPauseButtonTapCallback?, clearButtonTapCallback: ClearButtonTapCallback?, isPlayingQuery: IsPlayingQuery?) {
        self.playPauseButtonTapCallback = playPauseButtonTapCallback
        self.clearButtonTapCallback = clearButtonTapCallback
        self.isPlayingQuery = isPlayingQuery
    }
}

// MARK: SoundPlayerViewDelegate implementations

extension SoundPlayerPresenter: SoundPlayerViewDelegate {
    
    func playPauseButtonTapped() {
        self.playPauseButtonTapCallback?()
    }
    
    func clearButtonTapped() {
        self.clearButtonTapCallback?()
    }
    
    func isPlaying() -> Bool {
        return isPlayingQuery?() ?? false
    }
}
