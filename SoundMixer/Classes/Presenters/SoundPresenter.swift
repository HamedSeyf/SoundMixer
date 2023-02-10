//
//  SoundPresenter.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-05.
//

import Foundation


class SoundModelPresenter {
    
    typealias TapCallback = ((SoundModel)->Void)
    typealias IsSelectedQuery = ((SoundModel)->Bool)

    private weak var soundModel: SoundModel?
    private var tapCallback: TapCallback?
    private var isSelectedQuery: IsSelectedQuery?
    
    required init(_ soundModel: SoundModel, tapCallback: TapCallback?, isSelectedQuery: IsSelectedQuery?) {
        self.soundModel = soundModel
        self.tapCallback = tapCallback
        self.isSelectedQuery = isSelectedQuery
    }
}

// MARK: SoundViewDelegate implementations

extension SoundModelPresenter: SoundViewCellDelegate {
    
    func thumbnailTapped() {
        guard let model = soundModel else { return }
        
        tapCallback?(model)
    }
    
    func getThumbnailImageName(selected: Bool) -> String? {
        guard let imageAssetName = soundModel?.imageAssetName else { return nil }
        
        return "\(imageAssetName)-\(selected ? "Selected" : "Normal")"
    }
    
    func isSoundSelected() -> Bool {
        guard let model = soundModel, let isSelectedQuery = isSelectedQuery else { return false }
        
        return isSelectedQuery(model)
    }
}

// MARK: Equatable implementations

extension SoundModelPresenter: Equatable {
    
    static func ==(lhs: SoundModelPresenter, rhs: SoundModelPresenter) -> Bool {
        return lhs.soundModel == rhs.soundModel
    }
}
