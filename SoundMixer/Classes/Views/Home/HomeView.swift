//
//  HomeView.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-05.
//

import Foundation
import UIKit


class HomeView: UIView {
    
    private var yesTapCallback: (()->Void)?
    private var noTapCallback: (()->Void)?
    private var welcomeLabelView: UILabel!
    private var noLabelView: UILabel!
    private var yesLabelView: UILabel!
    
    required init(yesTapCallback: (()->Void)?, noTapCallback: (()->Void)?) {
        super.init(frame: .zero)
        
        self.yesTapCallback = yesTapCallback
        self.noTapCallback = noTapCallback
        
        backgroundColor = .white
        
        welcomeLabelView = UILabel()
        welcomeLabelView.contentMode = .center
        welcomeLabelView.text = "Welcome. Would you like to proceed?"
        welcomeLabelView.textColor = .black
        addSubview(welcomeLabelView)
        
        noLabelView = UILabel()
        noLabelView.contentMode = .center
        noLabelView.text = "No"
        noLabelView.textColor = .blue
        noLabelView.isUserInteractionEnabled = true
        let noTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleNoTap(_:)))
        noLabelView.addGestureRecognizer(noTapGestureRecognizer)
        addSubview(noLabelView)
        
        yesLabelView = UILabel()
        yesLabelView.contentMode = .center
        yesLabelView.text = "Yes"
        yesLabelView.textColor = .blue
        yesLabelView.isUserInteractionEnabled = true
        let yesTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleYesTap(_:)))
        yesLabelView.addGestureRecognizer(yesTapGestureRecognizer)
        addSubview(yesLabelView)
        
        let buttonsVerticalGap = 40.0
        welcomeLabelView.translatesAutoresizingMaskIntoConstraints = false
        noLabelView.translatesAutoresizingMaskIntoConstraints = false
        yesLabelView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            welcomeLabelView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            welcomeLabelView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            noLabelView.leftAnchor.constraint(equalTo: welcomeLabelView.leftAnchor),
            noLabelView.topAnchor.constraint(equalTo: self.welcomeLabelView.bottomAnchor, constant: buttonsVerticalGap),
            yesLabelView.rightAnchor.constraint(equalTo: welcomeLabelView.rightAnchor),
            yesLabelView.topAnchor.constraint(equalTo: self.welcomeLabelView.bottomAnchor, constant: buttonsVerticalGap)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Gesture recognizers

extension HomeView {
    
    @objc func handleYesTap(_ sender: UITapGestureRecognizer? = nil) {
        yesTapCallback?()
    }
    
    @objc func handleNoTap(_ sender: UITapGestureRecognizer? = nil) {
        noTapCallback?()
    }
}
