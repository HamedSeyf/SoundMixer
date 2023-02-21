//
//  SoundViewCell.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-03.
//

import Foundation
import UIKit


protocol SoundViewCellDelegate: AnyObject {
    
    func handleSongTap(tappedSong: any SoundModelToView)
}


class SoundViewCell: UICollectionViewCell {
    
    private enum VisualState {
        case normal
        case selected
    }
    
    weak var delegate: SoundViewCellDelegate?
    private var soundData: (any SoundModelToView)?
    private var thumbNailImage: UIImageView!
    private var ropeImage: UIImageView!
    private var state: VisualState = .normal {
        didSet {
            guard oldValue != state else { return }
            
            startThumbnailAnimation()
        }
    }
    
    private static let SelectedAnimationDuration: CGFloat = 0.35
    private static let SelectedAnimationScaleFactor: CGFloat = 1.15
    // This is based on the assets included in the bundle
    private static let MinimumCellSize = CGSize(width: 80, height: 120)
    private static let RopeImageBottomAdjustmentOffset = 20.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        
        ropeImage = UIImageView(image: UIImage(named: "Rope"))
        ropeImage.contentMode = .scaleAspectFit
        addSubview(ropeImage)
        
        thumbNailImage = UIImageView()
        thumbNailImage.contentMode = .scaleAspectFit
        thumbNailImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        thumbNailImage.addGestureRecognizer(tapGestureRecognizer)
        addSubview(thumbNailImage)
        
        ropeImage.translatesAutoresizingMaskIntoConstraints = false
        thumbNailImage.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            thumbNailImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            thumbNailImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ropeImage.centerXAnchor.constraint(equalTo: self.thumbNailImage.centerXAnchor),
            ropeImage.bottomAnchor.constraint(equalTo: thumbNailImage.bottomAnchor, constant: -SoundViewCell.RopeImageBottomAdjustmentOffset)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        delegate = nil
    }
    
    @MainActor func updateUI(soundData: any SoundModelToView) {
        self.soundData = soundData
        state = (soundData.isPlaying ? .selected : .normal)
        
        guard let imageName = soundData.getImageName(selected: (state == .selected)), let imageView = UIImage(named: imageName) else { assert(false, "Image not found.") }
        
        thumbNailImage.image = imageView
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let soundData = soundData else { return }
        delegate?.handleSongTap(tappedSong: soundData)
    }
    
    static func minimumRequiredSize() -> CGSize {
        return SoundViewCell.MinimumCellSize
    }
}

// MARK: Private methods

extension SoundViewCell {
    
    @MainActor private func startThumbnailAnimation() {
        let scaleFactor: CGFloat = (state == .selected ? SoundViewCell.SelectedAnimationScaleFactor : 1.0)
        let scaledTransform = CGAffineTransformScale(CGAffineTransformIdentity, scaleFactor, scaleFactor);
        UIView.animate(withDuration: SoundViewCell.SelectedAnimationDuration, animations: { [weak self] in
            self?.thumbNailImage.transform = scaledTransform
        })
    }
}
