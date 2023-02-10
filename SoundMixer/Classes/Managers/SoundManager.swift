//
//  SoundManager.swift
//  SoundMixer
//
//  Created by Hamed Seyf on 2023-02-05.
//

import Foundation
import AVFoundation


class SoundManager {
    
    private let dispatchQueue = DispatchQueue(label: "SoundManagerQueue")
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
    
    func playSound(_ soundFileName: String, checkExistingPlayback: Bool = true, fileExtenstion: String = "caf", completion: (()->Void)? = nil) {
        dispatchQueue.async { [weak self] in
            defer {
                completion?()
            }
            
            guard let url = SoundManager.getSoundURL(soundFileName, fileExtenstion: fileExtenstion) else { return }
            
            if checkExistingPlayback && self?.players.first(where: { $0.url == url }) != nil { return }
            
            guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
            guard let _ = try? self?.audioSession.setActive(true) else { return }
            
            self?.players.append(player)
            player.numberOfLoops = -1
            player.play()
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
    
    func playingSoundURLs() async -> [URL] {
        dispatchQueue.sync {
            return players.filter{ $0.url != nil }.map{ $0.url! }
        }
    }
    
    static func getSoundURL(_ soundFileName: String, fileExtenstion: String = "caf") -> URL? {
        return Bundle.main.url(forResource: soundFileName, withExtension: fileExtenstion)
    }
}
