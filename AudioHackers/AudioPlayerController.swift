//
//  AudioPlayerController.swift
//  AudioHackers
//
//  Created by Rich Ruais on 6/7/17.
//  Copyright © 2017 Rich Ruais. All rights reserved.
//

import Foundation
import AudioKit



class AudioPlayerController {
    
    static let sharedInstance = AudioPlayerController()
    
    var isPlaying = false
    var akPlayer: AKAudioPlayer!
    var akFile: AKAudioFile!
    var eq: AKEqualizerFilter!
    var envelope: AKAmplitudeEnvelope!
    var eqGain = 15.0
    
    
    func setupNotifications() {
        AKSettings.notificationsEnabled = true
        AKSettings.defaultToSpeaker = true
    }
    
    
    func loadInitialTrack(url: URL) {
        do {
            akFile = try AKAudioFile.init(forReading: url)
            akPlayer = try AKAudioPlayer(file: akFile)
        } catch {
            print(error)
        }
        akPlayer.looping = true
        eq = AKEqualizerFilter(akPlayer, centerFrequency: 0, bandwidth: 60, gain: eqGain)
        envelope = AKAmplitudeEnvelope(eq, attackDuration: 5.0, decayDuration: 1.0, sustainLevel: 1.0, releaseDuration: 1.0)
        envelope.play()
        envelope.rampTime = 0.5
        eq.rampTime = 1.0
        akPlayer.volume = 0.4
        AudioKit.output = envelope
        AudioKit.start()
    }
    
    func loadAudioFromURL(url: URL) {
        if AudioKit.engine.isRunning {
            AudioKit.stop()
            do {
                akFile = try AKAudioFile.init(forReading: url)
                akPlayer = try AKAudioPlayer(file: akFile)
            } catch {
                print(error)
            }
            akPlayer.looping = true
            eq = AKEqualizerFilter(akPlayer, centerFrequency: 0, bandwidth: 30, gain: eqGain)
            envelope = AKAmplitudeEnvelope(eq, attackDuration: 5.0, decayDuration: 1.0, sustainLevel: 1.0, releaseDuration: 1.0)
            envelope.play()
            envelope.rampTime = 0.5
            eq.rampTime = 1.0
            akPlayer.volume = 0.4
            AudioKit.output = envelope
            AudioKit.start()
            playPause()
        } else {
            do {
                akFile = try AKAudioFile.init(forReading: url)
                akPlayer = try AKAudioPlayer(file: akFile)
            } catch {
                print(error)
            }
            akPlayer.looping = true
            eq = AKEqualizerFilter(akPlayer, centerFrequency: 0, bandwidth: 30, gain: eqGain)
            envelope = AKAmplitudeEnvelope(eq, attackDuration: 5.0, decayDuration: 1.0, sustainLevel: 1.0, releaseDuration: 1.0)
            envelope.play()
            envelope.rampTime = 0.5
            eq.rampTime = 1.0
            akPlayer.volume = 0.4
            AudioKit.output = envelope
            AudioKit.start()
            playPause()
        }
    }
    
    func downloadFileFromURL(url: URL) {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in
            self.loadAudioFromURL(url: customURL!)
        })
        downloadTask.resume()
    }
    
    func startEq() {
        eq.start()
    }
    
    func stopEq() {
        eq.bypass()
    }
    
    func playPause() {
        if akPlayer.isPlaying {
            akPlayer.pause()
            isPlaying = false
        } else {
            akPlayer.play()
            isPlaying = true
        }
    }
    
    func pausePlayback() {
        if akPlayer.isPlaying {
            akPlayer.pause()
            isPlaying = false
        }
    }
    
    func dismissAudioEnv() {
        akPlayer.stop()
        AudioKit.stop()
    }
    
    // Guess Frequency Oscillator
    
    var oscillator = AKOscillator.init(waveform: AKTable(.sine))
    
    func setupGuessFreqAudioEnv() {
        oscillator.amplitude = 0.4
        envelope = AKAmplitudeEnvelope.init(oscillator, attackDuration: 1.0, decayDuration: 1.0, sustainLevel: 1.0, releaseDuration: 1.0)
        oscillator.rampTime = 0.1
        AudioKit.output = envelope
        AudioKit.start()
        envelope.start()
        
    }
    
    func dismissGuessFreqAudioEnv() {
        AudioKit.stop()
    }
    
    func playOscillator() {
        if oscillator.isPlaying {
            oscillator.stop()
            isPlaying = false
        } else {
            oscillator.start()
            isPlaying = true
        }

    }
    
    private init() {}
}
