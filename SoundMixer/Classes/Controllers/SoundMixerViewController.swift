//
//  SoundMixerViewController.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-03.
//

import Foundation
import UIKit
import MBProgressHUD


protocol SoundModelToView: AnyObject {
    func getImageName(selected: Bool) -> String?
    var soundAssetName: String? { get }
    var isPlaying: Bool { get }
    func isEqualTo(other: any SoundModelToView) -> Bool
}


protocol SoundMixerViewControllerToPresenter: AnyObject {
    func viewDidLoad()
    func playPauseButtonTapped()
    func clearButtonTapped()
    func handleSongTap(tappedSong: any SoundModelToView) async throws
    func doneButtonPressed()
}


class SoundMixerViewController: BaseViewController {
    
    private var soundMixerView: SoundMixerView!
    weak var presenter: SoundMixerViewControllerToPresenter?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        soundMixerView = SoundMixerView(delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor func updateViews(allSounds: [any SoundModelToView], playbackIsPaused: Bool) {
        soundMixerView.updateUI(allSounds: allSounds, playbackIsPaused: playbackIsPaused)
    }
    
    @MainActor func showErrorMessage(error: Error) {
        showAlertWithOK(title: "Error", message: error.localizedDescription)
    }
}

// MARK: UIViewController lifecycle

extension SoundMixerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonPressed))
        
        view.addSubview(soundMixerView)
        view.backgroundColor = .red
        
        presenter?.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        soundMixerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }
}

// MARK: Navigation

extension SoundMixerViewController {
    
    @objc func doneButtonPressed() {
        presenter?.doneButtonPressed()
    }
}

// MARK: SoundMixerViewDelegate

extension SoundMixerViewController: SoundMixerViewDelegate {
    
    func playPauseButtonTapped() {
        presenter?.playPauseButtonTapped()
    }
    
    func clearButtonTapped() {
        presenter?.clearButtonTapped()
    }
    
    func handleSongTap(tappedSong: any SoundModelToView) {
        Task() {
            do {
                try await presenter?.handleSongTap(tappedSong: tappedSong)
            } catch let error {
                showAlertWithOK(title: "Error", message: error.localizedDescription)
            }
        }
    }
}
