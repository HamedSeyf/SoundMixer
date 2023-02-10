//
//  SoundMixerPresenter.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-05.
//

import Foundation
import RealmSwift


class SoundMixerPresenter {
    
    private weak var model: PlaylistModel?
    private weak var MixerView: SoundMixerViewAnimationProtocol?
    private var notificationToken: NotificationToken!
    
    required init(model: PlaylistModel, MixerView: SoundMixerViewAnimationProtocol) {
        self.model = model
        self.MixerView = MixerView
        
        self.notificationToken = self.model?.songs.observe() { [weak self] changes in
            switch changes {
            case .initial(let songs), .update(let songs, _, _, _):
                self?.MixerView?.animatePlayerView(onScreen: songs.count > 0)
            case .error(let e):
                print(e.localizedDescription)
            }
        }
    }
}
