//
//  SoundsViewController.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-03.
//

import Foundation
import UIKit
import MBProgressHUD
import RealmSwift


class SoundsViewController: BaseViewController {
    
    private static let MaxPlayingSongs = 3
    
    private let soundManager = SoundManager()
    private var soundMixerView: SoundMixerView!
    private var playList: PlaylistModel!
    private var soundModelPresenters: [SoundModelPresenter]?
    private var soundPlayerPresenter: SoundPlayerPresenter!
    private var soundMixerPresenter: SoundMixerPresenter!
    private var playbackIsPaused = false
    
    private var soundModels: [SoundModel]? {
        didSet {
            refreshSoundModelPresenters()
            updateSoundManagerAndUI()
        }
    }
    
    static func presentSoundsViewController() {
        let soundsVC = SoundsViewController()
        let nc = UINavigationController(rootViewController: soundsVC)
        nc.modalPresentationStyle = .fullScreen
        UIApplication.shared.delegate?.window??.rootViewController?.present(nc, animated: true)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        if let playingList = Realm.shared?.objects(PlaylistModel.self).first {
            self.playList = playingList
        } else {
            self.playList = PlaylistModel()
            try? Realm.shared?.write {
                Realm.shared?.add(self.playList)
            }
        }
        
        soundPlayerPresenter = SoundPlayerPresenter(
            playPauseButtonTapCallback: { [weak self] in
                if let self = self {
                    self.playbackIsPaused = !self.playbackIsPaused
                    self.soundManager.changePlayPauseState(play: !self.playbackIsPaused)
                    self.updateUI()
                }
            },
            clearButtonTapCallback: { [weak self] in
                self?.playbackIsPaused = false
                try? Realm.shared?.write {
                    self?.playList.songs.removeAll()
                }
                self?.updateSoundManagerAndUI()
            },
            isPlayingQuery: { [weak self] in
                return (self?.playbackIsPaused == false) && (self?.playList.songs.count ?? 0 > 0)
            })
        
        soundMixerView = SoundMixerView()
        soundMixerPresenter = SoundMixerPresenter(model: playList, MixerView: soundMixerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UIViewController lifecycle

extension SoundsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonPressed))
        
        view.addSubview(soundMixerView)
        
        loadSoundModels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSoundManagerAndUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        soundMixerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }
}

// MARK: - Navigation

extension SoundsViewController {
    
    @objc func doneButtonPressed() {
        popOrDismiss(true)
    }
}

// MARK: Private methods

extension SoundsViewController {
    
    private func loadSoundModels() {
        DispatchQueue.dispatchMainIfNeeded { [weak self] in
            guard let view = self?.view else { return }
            
            MBProgressHUD.showAdded(to: view, animated: true)
        }
        
        Task.init() { [weak self] in
            DispatchQueue.dispatchMainIfNeeded { [weak self] in
                guard let view = self?.view else { return }
                
                MBProgressHUD.hide(for: view, animated: true)
            }
            
            if let savedSoundModels = Realm.shared?.objects(SoundModel.self), savedSoundModels.count > 0 {
                self?.soundModels = savedSoundModels.map{$0}
                return
            }
            
            let result: Result<[SoundModel]?, Object.JSONParseError> = await Object.loadModelsFromJSON("Sounds")
            switch result {
            case .success(let fetchedModels):
                try? Realm.shared?.write {
                    fetchedModels?.forEach {
                        Realm.shared?.add($0)
                    }
                }
                self?.soundModels = fetchedModels
            case .failure(_):
                let alert = UIAlertController(title: "Error", message: "Failed to load sound resources from JSON file", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    private func updateUI() {
        DispatchQueue.dispatchMainIfNeeded { [weak self] in
            guard let soundModelPresenters = self?.soundModelPresenters, let soundPlayerPresenter = self?.soundPlayerPresenter else { return }
            
            self?.soundMixerView.updateUI(allSounds: soundModelPresenters, soundPlayerPresenter: soundPlayerPresenter)
        }
    }
    
    private func refreshSoundModelPresenters() {
        Task() { [weak self] in
            var soundModelPresenters = [SoundModelPresenter]()
            self?.soundModels?.forEach({ SoundModel in
                let presenter = SoundModelPresenter(
                    SoundModel,
                    tapCallback: { model in
                        self?.handleSongTap(model)
                    },
                    isSelectedQuery: { model in
                        return self?.isSongSelected(model) ?? false
                    })
                soundModelPresenters.append(presenter)
            })
            self?.soundModelPresenters = soundModelPresenters
        }
    }
    
    private func handleSongTap(_ model: SoundModel) {
        playbackIsPaused = false
        
        if isSongSelected(model) {
            guard let index = playList.songs.index(of: model) else { return }
            
            try? Realm.shared?.write {
                playList.songs.remove(at: index)
            }
            updateSoundManagerAndUI()
        } else {
            guard playList.songs.count < SoundsViewController.MaxPlayingSongs else {
                let alert = UIAlertController(title: "Oooops", message: "Playing list is limited to \(SoundsViewController.MaxPlayingSongs) song\(SoundsViewController.MaxPlayingSongs > 1 ? "s" : "").\n", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                present(alert, animated: true)
                return
            }
            
            try? Realm.shared?.write {
                playList.songs.append(model)
            }
            updateSoundManagerAndUI()
        }
    }
    
    private func isSongSelected(_ model: SoundModel) -> Bool {
        return playList.songs.index(of: model) != nil
    }
    
    private func updateSoundManagerAndUI() {
        Task() {
            defer {
                Task { @MainActor in
                    updateUI()
                }
            }
            
            await soundManager.playingSoundURLs().forEach { soundURL in
                if playList.songs.first(where: { SoundManager.getSoundURL($0.soundAssetName ?? "") == soundURL }) == nil {
                    soundManager.stopPlayingSound(soundURL)
                }
            }
            for SoundModel in playList.songs {
                guard let soundAssetName = SoundModel.soundAssetName else { continue }
                
                soundManager.playSound(soundAssetName)
            }
        }
    }
}
