//
//  SoundPlayerView.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-04.
//

import Foundation
import UIKit


protocol SoundPlayerViewDelegate: AnyObject {
    func playPauseButtonTapped()
    func clearButtonTapped()
}

class SoundPlayerView: UIView {
    
    private weak var delegate: SoundPlayerViewDelegate?
    private var playPauseButton: PlayerButton!
    private var clearButton: PlayerButton!
    
    private static let ViewsBorderWidth: CGFloat = 1.0
    private static let ButtonsSize: CGFloat = 40.0
    private static let ButtonsHorizontalOffset: CGFloat = 40.0
    private static let BackgroundBorderRadius: CGFloat = 10.0
    
    required init(delegate: SoundPlayerViewDelegate) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        
        backgroundColor = UIColor.AppColors.playerBackground.color
        layer.borderWidth = SoundPlayerView.ViewsBorderWidth
        layer.borderColor = UIColor.AppColors.playerBorder.color.cgColor
        layer.cornerRadius = SoundPlayerView.BackgroundBorderRadius
        
        playPauseButton = PlayerButton(borderWidth: SoundPlayerView.ViewsBorderWidth)
        let playBtnTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handlePlayPauseButtonTap(_:)))
        playPauseButton.addGestureRecognizer(playBtnTapGestureRecognizer)
        addSubview(playPauseButton)
        
        clearButton = PlayerButton(borderWidth: SoundPlayerView.ViewsBorderWidth)
        let clearBtnTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleClearButtonTap(_:)))
        clearButton.addGestureRecognizer(clearBtnTapGestureRecognizer)
        clearButton.updateUI(imageName: "ButtonClear")
        addSubview(clearButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let centerX = round(frame.width * 0.5)
        let centerY = round(frame.height * 0.5)
        playPauseButton.frame = CGRect(x: centerX + SoundPlayerView.ButtonsHorizontalOffset, y: centerY - round(0.5 * SoundPlayerView.ButtonsSize), width: SoundPlayerView.ButtonsSize, height: SoundPlayerView.ButtonsSize)
        clearButton.frame = CGRect(x: centerX - SoundPlayerView.ButtonsHorizontalOffset - SoundPlayerView.ButtonsSize, y: centerY - round(0.5 * SoundPlayerView.ButtonsSize), width: SoundPlayerView.ButtonsSize, height: SoundPlayerView.ButtonsSize)
    }
    
    @MainActor func updateUI(playbackIsPaused: Bool) {
        playPauseButton.updateUI(imageName: playbackIsPaused ? "ButtonPlay" : "ButtonPause")
    }
}

// MARK: Gesture recognizers

extension SoundPlayerView {
    
    @objc func handlePlayPauseButtonTap(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.playPauseButtonTapped()
    }
    
    @objc func handleClearButtonTap(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.clearButtonTapped()
    }
}
