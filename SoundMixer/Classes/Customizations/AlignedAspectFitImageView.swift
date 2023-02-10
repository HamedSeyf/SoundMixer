//
//  AlignedAspectFitImageView.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-06.
//

import Foundation
import UIKit


@IBDesignable
class AlignedAspectFitImageView: UIView {
    
    @objc enum HorizontalAlignment: Int {
        case left, center, right
    }
    
    @objc enum VerticalAlignment: Int {
        case top, center, bottom
    }
    
    private var imageView = UIImageView()
    
    @IBInspectable var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            setNeedsLayout()
        }
    }
        
    @IBInspectable var aspectFill: Bool = false {
        didSet {
            guard oldValue != aspectFill else { return }
            setNeedsLayout()
        }
    }
    
    var horizontalAlignment: HorizontalAlignment = .center
    var verticalAlignment: VerticalAlignment = .center
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        commonInit()
    }
    
    private func commonInit() -> Void {
        clipsToBounds = true
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let img = imageView.image else {
            return
        }
        
        var newRect = bounds
        
        let viewRatio = bounds.size.width / bounds.size.height
        let imgRatio = img.size.width / img.size.height
        
        // if view ratio is equal to image ratio, we can fill the frame
        if viewRatio == imgRatio {
            imageView.frame = newRect
            return
        }
        
        var calcMode: Int = 1
        if aspectFill {
            calcMode = imgRatio > 1.0 ? 1 : 2
        } else {
            calcMode = imgRatio < 1.0 ? 1 : 2
        }

        if calcMode == 1 {
            // image is taller than wide
            let heightFactor = bounds.size.height / img.size.height
            let w = img.size.width * heightFactor
            newRect.size.width = w
            switch horizontalAlignment {
            case .center:
                newRect.origin.x = (bounds.size.width - w) * 0.5
            case .right:
                newRect.origin.x = bounds.size.width - w
            default: break  // left align - no changes needed
            }
        } else {
            // image is wider than tall
            let widthFactor = bounds.size.width / img.size.width
            let h = img.size.height * widthFactor
            newRect.size.height = h
            switch verticalAlignment {
            case .center:
                newRect.origin.y = (bounds.size.height - h) * 0.5
            case .bottom:
                newRect.origin.y = bounds.size.height - h
            default: break  // top align - no changes needed
            }
        }

        imageView.frame = newRect
    }
}
