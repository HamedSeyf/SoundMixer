//
//  SoundMixerPresenter.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-05.
//

import Foundation
import RealmSwift


class SoundMixerPresenter: SoundMixerPresenterToRouter {
    
    private static let MAX_PLAYING_SONGS = 3
    
    private(set) weak var viewController: SoundMixerViewController?
    private(set) var interactor: SoundMixerInteractor!
    
    private let soundManager = SoundManager()
    private var playbackIsPaused = false
    
    private class SoundDataForView: SoundModelToView, SoundModelToInteractor {
        
        private(set) var soundModelID: Int!
        private var imageAssetName: String?
        private(set) var soundAssetName: String?
        private(set) var isPlaying: Bool
        
        func getImageName(selected: Bool) -> String? {
            guard let imageAssetName = imageAssetName else { return nil }
            return "\(imageAssetName)-\(selected ? "Selected" : "Normal")"
        }
        required init(soundModel: SoundModel, playList: PlaylistModel) {
            self.soundModelID = soundModel._id
            self.isPlaying = playList.songs.contains(soundModel._id)
            self.imageAssetName = soundModel.imageAssetName
            self.soundAssetName = soundModel.soundAssetName
        }
        func isEqualTo(other: any SoundModelToView) -> Bool {
            guard let other = other as? SoundDataForView else { return false }
            return soundModelID == other.soundModelID
        }
    }
    
    private var soundsData = [SoundDataForView]()
    
    required init(vc: SoundMixerViewController?, interactor: SoundMixerInteractor) {
        self.viewController = vc
        self.interactor = interactor
        self.viewController?.presenter = self
    }
}

// MARK: SoundMixerViewControllerToPresenter protocol implementation

extension SoundMixerPresenter: SoundMixerViewControllerToPresenter {
    
    func viewDidLoad() {
        // TODO: Try to find a way to run these tasks on the private dispatchQueue
        Task() { [weak self] in
            await self?.reloadData()
        }
    }
    
    func playPauseButtonTapped() {
        Task() { [weak self] in
            guard let self = self else { return }
            self.playbackIsPaused = !self.playbackIsPaused
            self.soundManager.changePlayPauseState(play: !self.playbackIsPaused)
            await self.viewController?.updateViews(allSounds: self.soundsData, playbackIsPaused: self.playbackIsPaused)
        }
    }
    
    func clearButtonTapped() {
        Task() { [weak self] in
            do {
                try await self?.interactor.clearPlaylist()
            } catch let error {
                await self?.viewController?.showErrorMessage(error: error)
                return
            }
            self?.playbackIsPaused = false
            await self?.reloadData()
        }
    }
    
    func handleSongTap(tappedSong: any SoundModelToView) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Task() { [weak self] in
                guard let soundData = tappedSong as? SoundDataForView else { return }
                
                do {
                    try await interactor.reverseSongPlayingStatus(soundModelID: soundData.soundModelID, maxPlaying: SoundMixerPresenter.MAX_PLAYING_SONGS)
                    self?.playbackIsPaused = false
                    await self?.reloadData()
                    continuation.resume()
                } catch let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func doneButtonPressed() {
        Task() {
            await SoundMixerRouter.shared.dismissSoundsVC(animated: true)
        }
    }
}

// MARK: Private methods

extension SoundMixerPresenter {
    
    private func reloadData() async {
        let soundModelsFetchResult: Result<[SoundDataForView], SoundMixerInteractor.SoundMixerInteractorError> = await interactor.loadSoundsData()
        switch soundModelsFetchResult {
        case .success(let soundModelsData):
            soundsData = soundModelsData
            do {
                try await updateSoundManager(soundModelData: soundsData, removeThrowingSoundFromPlaylist: true)
            } catch let error {
                // TODO: Look into why accessing viewController property within async funcs requires an await keyword (has to do something with actors)
                await viewController?.showErrorMessage(error: error)
                await reloadData()
            }
            await viewController?.updateViews(allSounds: soundsData, playbackIsPaused: playbackIsPaused)
        case .failure(let error):
            soundsData.removeAll()
            await viewController?.updateViews(allSounds: soundsData, playbackIsPaused: playbackIsPaused)
            await viewController?.showErrorMessage(error: error)
            do {
                try await updateSoundManager(soundModelData: soundsData, removeThrowingSoundFromPlaylist: true)
            } catch let error {
                await viewController?.showErrorMessage(error: error)
            }
        }
    }
    
    private func updateSoundManager(soundModelData: [SoundDataForView], removeThrowingSoundFromPlaylist: Bool) async throws {
        for soundModelToView in soundModelData {
            guard let soundFileName = soundModelToView.soundAssetName else { continue }
            if soundModelToView.isPlaying {
                do {
                    try await soundManager.playSound(soundFileName)
                } catch let error {
                    if removeThrowingSoundFromPlaylist {
                        try? await interactor.reverseSongPlayingStatus(soundModelID: soundModelToView.soundModelID, maxPlaying: SoundMixerPresenter.MAX_PLAYING_SONGS)
                    }
                    throw error
                }
            } else {
                soundManager.stopPlayingSound(soundFileName)
            }
        }
    }
}
