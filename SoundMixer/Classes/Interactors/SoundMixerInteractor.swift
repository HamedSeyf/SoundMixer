//
//  SoundMixerInteractor.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-13.
//

import Foundation
import RealmSwift


protocol SoundModelToInteractor: AnyObject {
    init(soundModel: SoundModel, playList: PlaylistModel)
}


class SoundMixerInteractor {
    
    enum SoundMixerInteractorError: Error {
        case failedToWriteToRealm(error: Error)
        case jsonParseError(error: Object.JSONParseError)
        case maxPlayingReached(maxAllowed: Int)
    }
    
    func loadSoundsData<T>() async -> Result<[T], SoundMixerInteractorError> where T: SoundModelToInteractor {
        return await withCheckedContinuation { continuation in
            Realm.dispatchQueue.async {
                do {
                    let playList = try self.loadPlayList()
                    if let savedSoundModels = Realm.shared?.objects(SoundModel.self), savedSoundModels.count > 0 {
                        let soundModels: [SoundModel] = Array(savedSoundModels)
                        let soundData: [T] = self.constructSoundDataFromModels(with: soundModels, playList: playList)
                        return continuation.resume(returning: .success(soundData))
                    }
                    let result: Result<[SoundModel], Object.JSONParseError> = Object.loadModelsFromJSON("Sounds")
                    switch result {
                    case .success(let fetchedModels):
                        _ = try Realm.shared?.write {
                            fetchedModels.forEach {
                                Realm.shared?.add($0)
                            }
                        }
                        let soundData: [T] = self.constructSoundDataFromModels(with: fetchedModels, playList: playList)
                        return continuation.resume(returning: .success(soundData))
                    case .failure(let error):
                        return continuation.resume(returning: .failure(.jsonParseError(error: error)))
                    }
                } catch let error {
                    return continuation.resume(returning: .failure(.failedToWriteToRealm(error: error)))
                }
            }
        }
    }

    func loadPlayList() async throws -> PlaylistModel {
        return try await withCheckedThrowingContinuation { continuation in
            Realm.dispatchQueue.async {
                do {
                    let playList = try self.loadPlayList()
                    return continuation.resume(returning: playList)
                } catch let error {
                    return continuation.resume(throwing: SoundMixerInteractorError.failedToWriteToRealm(error: error))
                }
            }
        }
    }
    
    func clearPlaylist() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Realm.dispatchQueue.async {
                do {
                    let playList = try self.loadPlayList()
                    _ = try Realm.shared?.write {
                        playList.songs.removeAll()
                    }
                    return continuation.resume()
                } catch let error {
                    return continuation.resume(throwing: SoundMixerInteractorError.failedToWriteToRealm(error: error))
                }
            }
        }
    }
    
    func reverseSongPlayingStatus(soundModelID: Int, maxPlaying: Int) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Realm.dispatchQueue.async {
                do {
                    let playList = try self.loadPlayList()
                    if let index = playList.songs.firstIndex(of: soundModelID) {
                        _ = try Realm.shared?.write {
                            playList.songs.remove(at: index)
                        }
                    } else {
                        guard playList.songs.count < maxPlaying else {
                            return continuation.resume(throwing: SoundMixerInteractorError.maxPlayingReached(maxAllowed: maxPlaying))
                        }
                        
                        _ = try Realm.shared?.write {
                            playList.songs.append(soundModelID)
                        }
                    }
                    return continuation.resume()
                } catch let error {
                    return continuation.resume(throwing: SoundMixerInteractorError.failedToWriteToRealm(error: error))
                }
            }
        }
    }
}

// MARK: Private methods

extension SoundMixerInteractor {
    
    private func loadPlayList() throws -> PlaylistModel {
        if let playList = Realm.shared?.objects(PlaylistModel.self).first {
            return playList
        } else {
            let playList = PlaylistModel()
            do {
                _ = try Realm.shared?.write {
                    Realm.shared?.add(playList)
                }
            } catch let error {
                throw SoundMixerInteractorError.failedToWriteToRealm(error: error)
            }
            return playList
        }
    }
    
    private func constructSoundDataFromModels<T>(with soundModels: [SoundModel], playList: PlaylistModel) -> [T] where T: SoundModelToInteractor {
        var retVal = [T]()
        for soundModel in soundModels {
            let infant = T.init(soundModel: soundModel, playList: playList)
            retVal.append(infant)
        }
        return retVal
    }
}

// MARK: SoundMixerInteractorError description

extension SoundMixerInteractor.SoundMixerInteractorError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .jsonParseError(let error):
            return "Failed to parse JSON with error:\n\(error.localizedDescription)"
        case .maxPlayingReached(let maxAllowed):
            return "Playing list is limited to \(maxAllowed) song\(maxAllowed > 1 ? "s" : "").\n"
        case .failedToWriteToRealm(error: let error):
            return "Failed to write to Realm with error:\n\(error.localizedDescription)"
        }
    }
}
