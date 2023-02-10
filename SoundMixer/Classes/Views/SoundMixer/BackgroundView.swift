//
//  BackgroundView.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-03.
//

import Foundation
import UIKit


class BackgroundView: UIView {
    
    private var bgImageView: UIImageView!
    private var lakeImageView: AlignedAspectFitImageView!
    private var bottomGrassView: AlignedAspectFitImageView!
    
    private static let LakeImageBottomOffsetMultiplier = 0.02
    
    required init() {
        super.init(frame: .zero)
        
        isUserInteractionEnabled = false
        backgroundColor = .clear
        
        bgImageView = UIImageView(image: UIImage(named: "Background"))
        bgImageView.contentMode = .scaleToFill
        addSubview(bgImageView)
        
        lakeImageView = AlignedAspectFitImageView()
        lakeImageView.image = UIImage(named: "lake")
        lakeImageView.verticalAlignment = .bottom
        addSubview(lakeImageView)
        
        bottomGrassView = AlignedAspectFitImageView()
        bottomGrassView.image = UIImage(named: "BottomGrass")
        bottomGrassView.verticalAlignment = .bottom
        addSubview(bottomGrassView)
        
        sendSubviewToBack(bottomGrassView)
        sendSubviewToBack(lakeImageView)
        sendSubviewToBack(bgImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgImageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        bottomGrassView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let lakeViewOffset = frame.width * BackgroundView.LakeImageBottomOffsetMultiplier
        lakeImageView.frame = CGRect(x: 0, y: -lakeViewOffset, width: frame.width, height: frame.height)
    }
}
