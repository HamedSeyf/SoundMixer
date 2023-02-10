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
    
    private static let CellReuseIdentifier = "SoundViewCellIdentifier"
    private static let AdjacentColumnsVerticalDsiplacement: CGFloat = 20.0
    private static let AdjacentColumnsMinHorizontalSpace: CGFloat = 20.0
    
    required init() {
        super.init(frame: .zero, collectionViewLayout: layoutObject)
        
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
    
    func updateUI(allSounds: [SoundModelPresenter]?) {
        DispatchQueue.dispatchMainIfNeeded { [weak self] in
            self?.layoutObject.sounds = allSounds
            self?.layoutObject.updateUI()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutObject.constructSoundsMap()
    }
}

// MARK: SoundCollectionView's layout class

extension SoundCollectionView {
    
    class SoundMixerLayout: UICollectionViewLayout {
        
        var sounds: [SoundModelPresenter]? {
            didSet {
                guard sounds != oldValue else { return }
                
                constructSoundsMap()
            }
        }
        private(set) var soundsMap: [IndexPath : SoundModelPresenter]? {
            didSet {
                guard soundsMap != oldValue else { return }
                
                invalidateLayout()
                collectionView?.reloadData()
            }
        }
        private var cellLayoutAttributesCache = [IndexPath : UICollectionViewLayoutAttributes]()
        
        func constructSoundsMap() {
            guard let sounds = sounds, let (_, rowCount) = getSectionAndRowCount() else { return (soundsMap = nil) }
            
            var soundsArray = [IndexPath : SoundModelPresenter]()
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
        
        func updateUI() {
            DispatchQueue.dispatchMainIfNeeded { [weak self] in
                guard let collectionView = self?.collectionView else { return }
                
                let visibleIndexPaths = collectionView.indexPathsForVisibleItems
                visibleIndexPaths.forEach { indexPath in
                    (collectionView.cellForItem(at: indexPath) as? SoundViewCell)?.updateUI()
                }
            }
        }
        
        private func frameForItem(at indexPath: IndexPath) -> CGRect {
            guard let (rowCount, _) = getSectionAndRowCount(), rowCount > 0 else { return .zero }
            
            let sectionHeightOffset = (indexPath.section % 2 == 0 ? 0.0 : SoundCollectionView.AdjacentColumnsVerticalDsiplacement)
            let minimumCellSize = SoundViewCell.minimumRequiredSize()
//            let actualCellSize = collectionView?.frame.width
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
    }
}

// MARK: UICollectionViewDelegate implementations

extension SoundCollectionView.SoundMixerLayout: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SoundViewCell else { return }
        
        cell.updateUI()
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
        if let cell = cell as? SoundViewCell, let soundPresenter = soundsMap?[indexPath] {
            cell.delegate = soundPresenter
            cell.updateUI()
        }
        return cell
    }
}
