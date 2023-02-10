//
//  PlaylistModel.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-03.
//

import Foundation
import RealmSwift


@objcMembers class PlaylistModel: Object, Codable {
    
    dynamic var songs = List<SoundModel>()
}
