//
//  SoundManager.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-05.
//

import Foundation
import AVFoundation


class SoundManager {
    
    enum SoundManagerError: Error {
        case fileNotFound(fileName: String)
        case audioPlaybackFailed(error: Error)
    }
    
    private let dispatchQueue = DispatchQueue(label: "\(SoundManager.self)Queue")
    private var players = [AVAudioPlayer]()
    private var audioSession: AVAudioSession = {
        let sharedInstance = AVAudioSession.sharedInstance()
        do {
            try sharedInstance.setCategory(.playback, mode: .default)
        } catch let e {
            fatalError("Failed to setCategory on AVAudioSession.sharedInstance()")
        }
        return sharedInstance
    }()
    
    func changePlayPauseState(play: Bool, completion: (()->Void)? = nil) {
        dispatchQueue.async { [weak self] in
            defer {
                completion?()
            }
            
            self?.players.forEach {
                if play {
                    $0.play()
                } else {
                    $0.pause()
                }
            }
        }
    }
    
    func playSound(_ soundFileName: String, checkExistingPlayback: Bool = true, fileExtenstion: String = "caf") async throws {
        return try await withCheckedThrowingContinuation { continuation in
            dispatchQueue.async { [weak self] in
                guard let url = SoundManager.getSoundURL(soundFileName, fileExtenstion: fileExtenstion) else {
                    return continuation.resume(throwing: SoundManagerError.fileNotFound(fileName: soundFileName))
                }
                
                if checkExistingPlayback && self?.players.first(where: { $0.url == url }) != nil { return continuation.resume() }
                
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    _ = try self?.audioSession.setActive(true)
                    self?.players.append(player)
                    player.numberOfLoops = -1
                    player.play()
                    return continuation.resume()
                } catch let error {
                    return continuation.resume(throwing: SoundManagerError.audioPlaybackFailed(error: error))
                }
            }
        }
    }
    
    func stopPlayingSound(_ soundFileName: String, fileExtenstion: String = "caf", completion: (()->Void)? = nil) {
        dispatchQueue.async { [weak self] in
            defer {
                completion?()
            }
            
            guard let url = SoundManager.getSoundURL(soundFileName, fileExtenstion: fileExtenstion) else { return }
            
            self?.stopPlayingSound(url)
        }
    }
    
    func stopPlayingSound(_ url: URL, completion: (()->Void)? = nil) {
        dispatchQueue.async { [weak self] in
            defer {
                completion?()
            }
            
            self?.players.filter{ $0.url == url }.forEach { $0.stop() }
            self?.players.removeAll(where: { $0.url == url })
        }
    }
    
    func stopPlayingAllSound() {
        dispatchQueue.async { [weak self] in
            self?.players.forEach { player in
                player.stop()
            }
            self?.players.removeAll()
        }
    }
    
    func playingSoundURLs() async -> [URL] {
        dispatchQueue.sync {
            return players.filter{ $0.url != nil }.map{ $0.url! }
        }
    }
    
    static func getSoundURL(_ soundFileName: String, fileExtenstion: String = "caf") -> URL? {
        return Bundle.main.url(forResource: soundFileName, withExtension: fileExtenstion)
    }
}

// MARK: SoundManager description

extension SoundManager.SoundManagerError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "Sound file not found: \n\(fileName)"
        case .audioPlaybackFailed(let error):
            return "Failed to play audio with error:\n\(error.localizedDescription)"
        }
    }
}
