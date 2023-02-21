//
//  SoundCollectionView.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-04.
//

import Foundation
import UIKit



class SoundCollectionView: UICollectionView {
    
    private var layoutObject = SoundMixerLayout()
    private weak var viewDelegate: SoundViewCellDelegate?
    
    private static let CellReuseIdentifier = "SoundViewCellIdentifier"
    private static let AdjacentColumnsVerticalDsiplacement: CGFloat = 20.0
    private static let AdjacentColumnsMinHorizontalSpace: CGFloat = 20.0
    
    required init(delegate: SoundViewCellDelegate) {
        super.init(frame: .zero, collectionViewLayout: layoutObject)
        
        viewDelegate = delegate
        self.backgroundColor = .clear
        self.isScrollEnabled = true
        self.bounces = true
        self.alwaysBounceHorizontal = true
        self.delegate = layoutObject
        self.dataSource = layoutObject
        self.register(SoundViewCell.self, forCellWithReuseIdentifier: SoundCollectionView.CellReuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor func updateUI(allSounds: [any SoundModelToView]) {
        layoutObject.updateUI(allSounds: allSounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutObject.constructSoundsMap()
    }
}

// MARK: SoundCollectionView's layout class

extension SoundCollectionView {
    
    class SoundMixerLayout: UICollectionViewLayout {
        
        var sounds: [any SoundModelToView]? {
            didSet {
                constructSoundsMap()
            }
        }
        private(set) var soundsMap: [IndexPath : any SoundModelToView]? {
            didSet {
                guard !SoundMixerLayout.soundMapsAreEqual(lhs: soundsMap, rhs: oldValue) else { return }
                
                invalidateLayout()
                collectionView?.reloadData()
            }
        }
        private var cellLayoutAttributesCache = [IndexPath : UICollectionViewLayoutAttributes]()
        
        func constructSoundsMap() {
            guard let sounds = sounds, let (_, rowCount) = getSectionAndRowCount() else { return (soundsMap = nil) }
            
            var soundsArray = [IndexPath : any SoundModelToView]()
            sounds.indices.forEach { soundIndex in
                let sound = sounds[soundIndex]
                let index = IndexPath(row: soundIndex % rowCount, section: soundIndex / rowCount)
                soundsArray[index] = sound
            }
            soundsMap = soundsArray
        }
        
        override func prepare() {
            super.prepare()
            
            cellLayoutAttributesCache = [ : ]
            constructSoundsMap()
            
            guard let allSounds = soundsMap else { return }
            
            for indexPath in allSounds.keys {
                cellLayoutAttributesCache[indexPath] = layoutAttributesForItem(at: indexPath)
            }
        }
        
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            return cellLayoutAttributesCache.values.filter {
                rect.intersects($0.frame)
            }
        }

        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            if cellLayoutAttributesCache[indexPath] != nil {
                return cellLayoutAttributesCache[indexPath]
            }
                
            let frame = frameForItem(at: indexPath)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            
            return attributes
        }
        
        override func invalidateLayout() {
            cellLayoutAttributesCache = [:]

            super.invalidateLayout()
        }
        
        override var collectionViewContentSize: CGSize {
            var unionRect = CGRect.zero
            cellLayoutAttributesCache.values.forEach() {
                unionRect = unionRect.union($0.frame)
            }
            return unionRect.size
        }
        
        @MainActor func updateUI(allSounds: [any SoundModelToView]) {
            // TODO: This also might need its own queue
            sounds = allSounds
            
            guard let collectionView = collectionView else { return }

            let visibleIndexPaths = collectionView.indexPathsForVisibleItems
            for indexPath in visibleIndexPaths {
                guard let soundData = soundsMap?[indexPath] else { continue }
                (collectionView.cellForItem(at: indexPath) as? SoundViewCell)?.updateUI(soundData: soundData)
            }
        }
        
        private func frameForItem(at indexPath: IndexPath) -> CGRect {
            guard let (rowCount, _) = getSectionAndRowCount(), rowCount > 0 else { return .zero }
            
            let sectionHeightOffset = (indexPath.section % 2 == 0 ? 0.0 : SoundCollectionView.AdjacentColumnsVerticalDsiplacement)
            let minimumCellSize = SoundViewCell.minimumRequiredSize()
            let x = AdjacentColumnsMinHorizontalSpace + (minimumCellSize.width + AdjacentColumnsMinHorizontalSpace) * CGFloat(indexPath.section)
            let y = sectionHeightOffset + CGFloat(indexPath.row) * minimumCellSize.height
            
            return CGRect(x: x, y: y, width: minimumCellSize.width, height: minimumCellSize.height)
                
        }
        
        private func getSectionAndRowCount() -> (sectionCount: Int, rowCount: Int)? {
            guard let allSounds = sounds, allSounds.count > 0, let collectionView = collectionView else { return nil }
            
            let minimumCellSize = SoundViewCell.minimumRequiredSize()
            let availableHeight = floor(collectionView.frame.height - SoundCollectionView.AdjacentColumnsVerticalDsiplacement)
            let rowCount = Int(availableHeight) / Int(minimumCellSize.height)
            
            guard rowCount > 0 else { return nil }
            
            let sectionCount = (allSounds.count + rowCount - 1) / rowCount
            return (sectionCount, rowCount)
        }
        
        private static func soundMapsAreEqual(lhs: [IndexPath : any SoundModelToView]?, rhs: [IndexPath : any SoundModelToView]?) -> Bool {
            guard lhs != nil || rhs != nil else { return true }
            
            guard let lhs = lhs, let rhs = rhs, lhs.count == rhs.count else { return false }
            
            for (key, value) in lhs {
                guard let otherValue = rhs[key], value.isEqualTo(other: otherValue) else { return false }
            }
            
            return true
        }
    }
}

// MARK: UICollectionViewDelegate implementations

extension SoundCollectionView.SoundMixerLayout: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SoundViewCell, let soundData = soundsMap?[indexPath] else { return }

        cell.updateUI(soundData: soundData)
    }
}

// MARK: UICollectionViewDataSource implementations

extension SoundCollectionView.SoundMixerLayout: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return soundsMap?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let soundsMap = soundsMap else { return 0 }
        
        return soundsMap.filter({ $0.key.section == section }).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SoundCollectionView.CellReuseIdentifier, for: indexPath)
        if let collectionView = collectionView as? SoundCollectionView, let cell = cell as? SoundViewCell, let soundData = soundsMap?[indexPath] {
            cell.delegate = collectionView.viewDelegate
            cell.updateUI(soundData: soundData)
        }
        return cell
    }
}
