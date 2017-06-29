//
//  GuessFrequencyViewController.swift
//  AudioHackers
//
//  Created by Rich Ruais on 5/31/17.
//  Copyright © 2017 Rich Ruais. All rights reserved.
//

import UIKit
import AudioKit
import Firebase

var masterGameTime = 60

class GuessFrequencyViewController: UIViewController {
    
    let gc = GameController()
    var gameTime = masterGameTime
    var timer = Timer()
    var gameOverAlertController = UIAlertController()
    var gameOverAlertIsActive = false
    var gameIsActive = false
    let userDefaults = Foundation.UserDefaults.standard
    
    @IBOutlet weak var answer1: UIButton!
    @IBOutlet weak var answer2: UIButton!
    @IBOutlet weak var answer3: UIButton!
    @IBOutlet weak var answer4: UIButton!
    @IBOutlet weak var answer5: UIButton!
    @IBOutlet weak var roundLbl: UILabel!
    @IBOutlet weak var gameTimelbl: UILabel!
    @IBOutlet weak var frequencyLbl: UILabel!
    @IBOutlet weak var frequencyTextLbl: UILabel!
    @IBOutlet weak var correctAnswerLbl: UILabel!
    @IBOutlet weak var correntAnswerTextLbl: UILabel!
    @IBOutlet weak var correctLbl: UILabel!
    @IBOutlet weak var oscillatorGainOutlet: UISlider!
    @IBOutlet weak var startGameBtnLbl: UIButton!
    @IBOutlet weak var restartBtnLbl: UIBarButtonItem!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var infoBtnLbl: UIButton!
    @IBOutlet weak var oscOnOffLbl: UILabel!
    @IBOutlet weak var oscVolumeLbl: UILabel!
    
    let playImage = UIImage(named: "Play")
    let pauseImage = UIImage(named: "Pause")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioEnv()
        disableGameBtns()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        volumeWarning()
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0.4
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = Float.greatestFiniteMagnitude
        startGameBtnLbl.layer.add(pulseAnimation, forKey: "animateOpacity")

    }
    
    func enableGameBtns() {
        // Start Btn
        startGameBtnLbl.isEnabled = false
        startGameBtnLbl.isHidden = true
        // Game btns
        playBtn.isEnabled = true
        oscillatorGainOutlet.isEnabled = true
        answer1.isEnabled = true
        answer2.isEnabled = true
        answer3.isEnabled = true
        answer4.isEnabled = true
        answer5.isEnabled = true
        oscOnOffLbl.isHidden = true
        oscVolumeLbl.isHidden = true
        
        correntAnswerTextLbl.isHidden = false
        frequencyTextLbl.isHidden = false
        
        restartBtnLbl.isEnabled = true
        
    }
    
    func disableGameBtns() {
        // Start Btn
        startGameBtnLbl.isEnabled = true
        startGameBtnLbl.isHidden = false
        // Game Btns
        playBtn.isEnabled = false
        oscillatorGainOutlet.isEnabled = false
        answer1.isEnabled = false
        answer2.isEnabled = false
        answer3.isEnabled = false
        answer4.isEnabled = false
        answer5.isEnabled = false
        oscOnOffLbl.isHidden = true
        oscVolumeLbl.isHidden = true
        
        correctAnswerLbl.isHidden = true
        correctLbl.isHidden = true
        frequencyLbl.isHidden = true
        correntAnswerTextLbl.isHidden = true
        frequencyTextLbl.isHidden = true
        
        restartBtnLbl.isEnabled = false
        gc.gameRound = 0
        roundLbl.text = String(gc.gameRound)
        gameTime = masterGameTime
        gameTimelbl.text = String(gameTime)
        
    }

    func setupAudioEnv() {
        AudioPlayerController.sharedInstance.setupGuessFreqAudioEnv()
        oscillatorGainOutlet.value = Float(AudioPlayerController.sharedInstance.oscillator.amplitude)

    }

    func startNewRound() {
        roundLbl.text = String(gc.gameRound)
        gc.currentFrequency = gc.getRandomFrequency()
        AudioPlayerController.sharedInstance.oscillator.frequency = Double(gc.currentFrequency)
        play()
    }
    
 
    @IBAction func startGameBtn(_ sender: Any) {
        gameIsActive = true
        infoBtnLbl.isEnabled = false
        enableGameBtns()
        startGame()
    }

    func startGame() {
        // Reset game variables
        gc.correctPercentage = 0
        gc.gameRound = 0
        gc.numberCorrect = 0
        gc.numberIncorrect = 0
        // Connect variables to labels
        roundLbl.text = String(gc.gameRound)
        oscillatorGainOutlet.value = Float(AudioPlayerController.sharedInstance.oscillator.amplitude)
        // Setup game time
        gameTime = masterGameTime
        gameTimelbl.text = String(gameTime)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GuessFrequencyViewController.counter), userInfo: nil, repeats: true)
        startNewRound()
    }
    
    func counter() {
        gameTime -= 1
        gameTimelbl.text = String(gameTime)
        if gameTime <= 0 {
            if AudioPlayerController.sharedInstance.isPlaying {
                AudioPlayerController.sharedInstance.oscillator.stop()
            }
            timer.invalidate()
            // Update Percentage
            gc.correctPercentage = calculatePercentage(total: gc.gameRound, correct: gc.numberCorrect)
            let newScore = Score.init(numberCorrect: gc.numberCorrect, numberIncorrect: gc.numberIncorrect, percentage: gc.correctPercentage, round: gc.gameRound, userId: "", createdAt: "")
            
            // Retrieve and save high scores if connected to internet
            if Connectivity.isConnectedToInternet() {
                gc.retrieveHighScores(path: "GuessFreqHighScores", pathForDefaults: "currentFreqHighScores")
                if let value  = userDefaults.array(forKey: "currentFreqHighScores") {
                        let scores = value as! [[String : String]]
                        var isGreater = false
                    if Int(newScore.round) >= 10 {
                        if scores.count >= 10 {
                            for index in 0..<scores.count {
                                let temp = scores[index]["percentage"]
                                if Float(newScore.percentage) > Float(temp!)! {
                                    isGreater = true
                                }
                            }
                            if isGreater == true {
                                gc.saveHighScore(newScore: newScore, path: "GuessFreqHighScores")
                                let min = findMin(arr: scores)
                                print("min       \(min)")
                                let scoreToDelete = scores[min]
                                gc.deleteScore(scoreToDelete: scoreToDelete, path: "GuessFreqHighScores")
                            } else {
                            }
                        } else {
                            gc.saveHighScore(newScore: newScore, path: "GuessFreqHighScores")
                            print("There are less than 10 scores: \(scores.count)")
                        }
                    }
                }
            }
            
            let message = "Total Rounds: \(newScore.round)\nTotal Correct: \(newScore.numberCorrect)\nTotal Incorrect: \(newScore.numberIncorrect)\nFinal Percentage: \(newScore.percentage)"
            let alertTitle = "Game Over"
            gameOverAlertController = UIAlertController(title: alertTitle, message: message, preferredStyle: .actionSheet)
            let actionItem = UIAlertAction(title: "Start new game", style: .default) { [weak self]
                action in
                self?.disableGameBtns()
                self?.infoBtnLbl.isEnabled = true
                self?.gameOverAlertIsActive = false
                self?.gameIsActive = false
            }
            let actionItem2 = UIAlertAction(title: "Main Menu", style: .default) { [weak self]
                action in
                AudioPlayerController.sharedInstance.dismissGuessFreqAudioEnv()
                self?.dismiss(animated: false, completion: nil)
            }
           
            gameOverAlertController.addAction(actionItem)
            gameOverAlertController.addAction(actionItem2)
            
            present(gameOverAlertController, animated: true) {
                AudioPlayerController.sharedInstance.oscillator.stop()
                self.gameOverAlertIsActive = true
                self.gameIsActive = false
            }
        }
    }
    

    
    @IBAction func playOscillator(_ sender: UIButton) {
        play()
    }
    
    func play() {
        AudioPlayerController.sharedInstance.playOscillator()
        if AudioPlayerController.sharedInstance.isPlaying {
            playBtn.setImage(pauseImage , for: .normal)
        } else {
            playBtn.setImage(playImage , for: .normal)
        }
    }
    
    @IBAction func answerSelected(_ sender: UIButton) {
        
        AudioPlayerController.sharedInstance.oscillator.stop()
        playBtn.setImage(playImage , for: .normal)
        
        switch sender.tag {
        case 1:
            if gc.frequencyRanges[0].contains(gc.currentFrequency) {
                gc.answerIndex = 0
                gc.isCorrect = true
            } else {
                gc.answerIndex = 0
                gc.isCorrect = false
            }
        case 2:
            if gc.frequencyRanges[1].contains(gc.currentFrequency) {
                gc.answerIndex = 1
                gc.isCorrect = true
            } else {
                gc.answerIndex = 1
                gc.isCorrect = false            }
        case 3:
            if gc.frequencyRanges[2].contains(gc.currentFrequency) {
                gc.answerIndex = 2
                gc.isCorrect = true
            } else {
                gc.answerIndex = 2
                gc.isCorrect = false
            }
        case 4:
            if gc.frequencyRanges[3].contains(gc.currentFrequency) {
                gc.answerIndex = 3
                gc.isCorrect = true
            } else {
                gc.answerIndex = 3
                gc.isCorrect = false
            }
        case 5:
            if gc.frequencyRanges[4].contains(gc.currentFrequency) {
                gc.answerIndex = 4
                gc.isCorrect = true
            } else {
                gc.answerIndex = 4
                gc.isCorrect = false
            }
        default:
            return
        }
        
        // Set correct answer
        for i in 0..<gc.frequencyRanges.count {
            if gc.frequencyRanges[i].contains(gc.currentFrequency) {
                gc.correctAnswer = gc.freqRangeStrings[i]
            }
        }
        
        // Update Score and Labels
        if gc.isCorrect {
            gc.numberCorrect += 1
           
        } else {
            gc.numberIncorrect += 1
            
        }
        
        let frequency = String(gc.currentFrequency)
//        let yourGuess = String(gc.freqRangeStrings[gc.answerIndex])
        let correctAnswer = gc.correctAnswer
        
        correctLbl.isHidden = false
        frequencyLbl.text = frequency
        correctAnswerLbl.text = correctAnswer
        correctAnswerLbl.isHidden = false
        frequencyLbl.isHidden = false
        
        
        if gc.isCorrect {
            correctLbl.text = "Correct!"
            correctLbl.textColor = UIColor.green
        } else {
            correctLbl.text = "Incorrect"
            correctLbl.textColor = UIColor.red
        }
        
        gc.gameRound += 1
        startNewRound()
    }
    
    @IBAction func oscillatorGainSlider(_ sender: UISlider) {
        
        sender.maximumValue = 0.8
        sender.minimumValue = 0.0
        AudioPlayerController.sharedInstance.oscillator.amplitude = Double(sender.value)
    }

    
    @IBAction func restart(_ sender: Any) {
        let actionTitle = "Are you sure you want to restart?"
        let actionMessage = "Your current game data will be lost."
        let alertController = UIAlertController(title: actionTitle, message: actionMessage, preferredStyle: .actionSheet)
        let actionItem = UIAlertAction(title: "Restart", style: .destructive) { [weak self]
            action in
            self?.disableGameBtns()
            self?.gameIsActive = false
            self?.infoBtnLbl.isEnabled = true
        }
        let actionItem2 = UIAlertAction(title: "Cancel", style: .cancel) { [weak self]
            action in
            self?.timer = Timer.scheduledTimer(timeInterval: 1, target: self!, selector: #selector(GuessFrequencyViewController.counter), userInfo: nil, repeats: true)
        }
        
        alertController.addAction(actionItem)
        alertController.addAction(actionItem2)
        
        if !gameOverAlertIsActive {
            present(alertController, animated: true) {
                AudioPlayerController.sharedInstance.oscillator.stop()
                self.playBtn.setImage(self.playImage , for: .normal)
                self.timer.invalidate()
            }
        }
        
    }

    @IBAction func homeAction(_ sender: Any) {
        let actionTitle = "Are you sure you want to exit?"
        let actionMessage = "Your current game data will be lost."
        let alertController = UIAlertController(title: actionTitle, message: actionMessage, preferredStyle: .actionSheet)
        let actionItem = UIAlertAction(title: "Exit", style: .destructive) { [weak self]
            action in
            AudioPlayerController.sharedInstance.dismissGuessFreqAudioEnv()
            self?.dismiss(animated: false, completion: nil)
        } 
        let actionItem2 = UIAlertAction(title: "Cancel", style: .cancel) { [weak self]
            action in
            if self?.gameIsActive == true {
                self?.timer = Timer.scheduledTimer(timeInterval: 1, target: self!, selector: #selector(GuessFrequencyViewController.counter), userInfo: nil, repeats: true)
            }
            
        }

        alertController.addAction(actionItem)
        alertController.addAction(actionItem2)
        
        if !gameOverAlertIsActive {
            present(alertController, animated: true) {
                AudioPlayerController.sharedInstance.oscillator.stop()
                self.playBtn.setImage(self.playImage , for: .normal)
                self.timer.invalidate()
            }

        }
        
    }
    
    
    // Helpers
    func calculatePercentage(total: Int, correct: Int) -> Double {
        
        let divisionAmount = Double(correct) / Double(total)
        let percent = divisionAmount * 100
        print(percent)
        return Double(percent)
    }
    
    func volumeWarning() {
        let actionTitle = "Warning!"
        let actionMessage = "Loud playback of audio can be damaging to your ears!\n\nLower your phone's volume level before starting game."
        let alertController = UIAlertController(title: actionTitle, message: actionMessage, preferredStyle: .alert)
        let actionItem = UIAlertAction(title: "Ok", style: .cancel) {
            action in
        }
        alertController.addAction(actionItem)
        present(alertController, animated: true)
    }
    
    func findMin(arr: [[String : String]]) -> Int {
        let min = arr[0]["percentage"]
        var floatMin = Float(min!)
        var minIndex = 0
        for index in 0..<arr.count {
            let temp = Float(arr[index]["percentage"]!)
            if temp! < floatMin! {
                floatMin = temp
                minIndex = index
            }
        }
        return minIndex
    }


}
