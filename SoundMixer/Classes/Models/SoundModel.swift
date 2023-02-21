//
//  SoundModel.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-03.
//

import Foundation
import RealmSwift


@objcMembers class SoundModel: Object, Codable {
    
    dynamic var _id: Int
    dynamic var imageAssetName: String?
    dynamic var soundAssetName: String?
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}
