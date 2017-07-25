//
//  GuessFrequencyController.swift
//  AudioHackers
//
//  Created by Rich Ruais on 6/1/17.
//  Copyright © 2017 Rich Ruais. All rights reserved.
//

import Foundation
import Firebase

struct Score {
    var numberCorrect: Int
    var numberIncorrect: Int
    var percentage: Double
    var round: Int
    var userId: String
    var createdAt: String
}

class GameController {
    // Game Variables
    var gameRound = 0
    var score = 0
    var currentFrequency = Int()
    var correctAnswer = String()
    var answerText = String()
    var answerIndex = Int()
    var correctAnswerIndex = Int()
    var isCorrect = Bool()
    var numberCorrect = 0
    var numberIncorrect = 0
    var correctPercentage = 0.00
    
    let frequencyRanges = [50..<101,100..<251, 251..<2501, 2502..<7501, 7501..<15000]
    let freqRangeStrings = ["Low: 20 - 100", "Low Mid: 101 - 250", "Mid: 251 - 2500", "High Mid: 2501 - 7500", "High: 7501 - 17000"]

    
    func getRandomFrequency() -> Int {
        let randNum = randomIntFrom(start: 0, to: frequencyRanges.count - 1)
        print("RandNum    \(randNum)")
        let range = frequencyRanges[randNum]
        print("range    \(range)")
        let freq = randomIntFrom(start: Int(range.startIndex), to: Int(range.endIndex - 1))
        print("freq     \(freq)")
        return freq
    }
     
    func randomIntFrom(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        // swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
    
    func saveHighScore(newScore: Score, path: String) {
        let date = Date()
        var newScore = newScore
        let userId = currentGoogleUser.id
        newScore.userId = userId
        newScore.createdAt = String(describing: date)
        
        var scoreToSave = [String:String]()
        scoreToSave = ["numberCorrect": String(newScore.numberCorrect), "numberIncorrect": String(newScore.numberIncorrect), "percentage": String(newScore.percentage), "userId": String(newScore.userId), "round": String(newScore.round), "createdAt": newScore.createdAt]
        
        let ref = FIRDatabase.database().reference(withPath: path).child(newScore.userId)
        
        let scoreRef = ref.child("\(date)")
        scoreRef.setValue(scoreToSave) { (error, ref) -> Void in
            print(error.debugDescription)
            print(error?.localizedDescription as Any)
            
        }
        
    }
    
    func retrieveHighScores(path: String, pathForDefaults: String) {
        var currentHighScores = [[String: String]]()
        
        FIRDatabase.database().reference(withPath: path).child(currentGoogleUser.id).observeSingleEvent(of: .value, with: { (snapshot) in
         
            if let dictionary = snapshot.value as? [String: Any] {
                for (_, value) in dictionary {
                    var object = value as! [String: Any]
                    let numberCorrect = object["numberCorrect"] as! String
                    let numberIncorrect = object["numberIncorrect"] as! String
                    let percentage = object["percentage"] as! String
                    let round = object["round"] as! String
                    let userId = object["userId"] as! String
                    let createdAt = object["createdAt"] as! String
                    let newScore: [String: String] = ["numberCorrect": numberCorrect, "numberIncorrect": numberIncorrect, "percentage": percentage, "round": round, "userId": userId, "createdAt": createdAt]
                    currentHighScores.append(newScore)
                }
              
                let userDefaults = Foundation.UserDefaults.standard
                userDefaults.set( currentHighScores, forKey: pathForDefaults)
            }
            

        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func deleteScore(scoreToDelete: [String : String], path: String) {
        let createdAt = scoreToDelete["createdAt"]
        print("createdAt       \(String(describing: createdAt))")
        let ref = FIRDatabase.database().reference(withPath: path)
        ref.child(currentGoogleUser.id).child(createdAt!).removeValue { (error, ref) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
        print("Successfully Deleted Score")
    }
    
}
