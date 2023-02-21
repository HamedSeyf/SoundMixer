//
//  PlayerButton.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-04.
//

import Foundation
import UIKit


class PlayerButton: UIView {
    
    private var imageView: UIImageView!
    
    required init(borderWidth: CGFloat) {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        layer.borderWidth = borderWidth
        layer.borderColor = UIColor.AppColors.playerButton.color.cgColor
        isUserInteractionEnabled = true        
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.AppColors.playerButton.color
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = round(min(frame.width, frame.height) * 0.5)
        
        let imageSize = round(min(frame.width, frame.height) * 0.5)
        imageView.frame = CGRect(x: round((frame.width - imageSize) * 0.5), y: round((frame.height - imageSize) * 0.5), width: imageSize, height: imageSize)
    }
    
    @MainActor func updateUI(imageName: String) {
        imageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
    }
}
