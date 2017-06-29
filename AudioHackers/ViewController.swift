//
//  ViewController.swift
//  AudioHackers
//
//  Created by Rich Ruais on 5/31/17.
//  Copyright © 2017 Rich Ruais. All rights reserved.
//

import UIKit
import Firebase

struct googleUser {
    var displayName = String()
    var email = String()
    var id = String()
}

var currentGoogleUser = googleUser.init(displayName: "", email: "", id: "")

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var gmailLbl: UILabel!
    @IBOutlet weak var welcomeUserLbl: UILabel!
    @IBOutlet weak var guessFrequencyBtn: UIButton!
    @IBOutlet weak var guessFrequencyLbl: UILabel!
    @IBOutlet weak var GuessEqBtn: UIButton!
    @IBOutlet weak var guessEqLbl: UILabel!
    @IBOutlet weak var signOut: UIBarButtonItem!
    @IBOutlet weak var googleSignInBtn: UIButton!
    @IBOutlet weak var highScoreBtn: UIBarButtonItem!
    @IBOutlet weak var guessEqLogo: UIButton!
    @IBOutlet weak var guessFreqLogo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Audio Notifications - Defaul to speaker
        AudioPlayerController.sharedInstance.setupNotifications()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        checkLoggedInStatus()
        
        // Hide before animation
        guessFrequencyLbl.isHidden = true
        guessFrequencyBtn.isHidden = true
        guessFreqLogo.isHidden = true
        guessEqLbl.isHidden = true
        GuessEqBtn.isHidden = true
        guessEqLogo.isHidden = true
        googleSignInBtn.isHidden = true
        gmailLbl.isHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Hide for animation when view is loaded again
        guessFrequencyLbl.isHidden = true
        guessFrequencyBtn.isHidden = true
        guessFreqLogo.isHidden = true
        guessEqLbl.isHidden = true
        GuessEqBtn.isHidden = true
        guessEqLogo.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        guessFrequencyLbl.center.x -= view.bounds.width
        guessEqLbl.center.x += view.bounds.width
        guessFreqLogo.center.x -= view.bounds.width
        guessEqLogo.center.x += view.bounds.width
        guessFrequencyBtn.center.x -= view.bounds.width
        GuessEqBtn.center.x += view.bounds.width
        
        guessFrequencyLbl.isHidden = false
        guessFrequencyBtn.isHidden = false
        guessFreqLogo.isHidden = false
        guessEqLbl.isHidden = false
        GuessEqBtn.isHidden = false
        guessEqLogo.isHidden = false
        
        UIView.animate(withDuration: 0.7, delay: 0.5,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.5,
                       options: [], animations: {
                        self.guessFrequencyLbl.center.x += self.view.bounds.width
                        self.guessEqLbl.center.x -= self.view.bounds.width
                        self.guessFreqLogo.center.x += self.view.bounds.width
                        self.guessEqLogo.center.x -= self.view.bounds.width
                        self.guessFrequencyBtn.center.x += self.view.bounds.width
                        self.GuessEqBtn.center.x -= self.view.bounds.width
        }, completion: nil)
        
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0.4
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = Float.greatestFiniteMagnitude
        guessFrequencyLbl.layer.add(pulseAnimation, forKey: "animateOpacity")
        guessEqLbl.layer.add(pulseAnimation, forKey: "animateOpacity")
        
    }
    
    func checkLoggedInStatus() {
        FIRAuth.auth()?.addStateDidChangeListener { (auth, user) in
            if user != nil {
                currentGoogleUser.email = (user?.email)!
                currentGoogleUser.displayName = (user?.displayName)!
                currentGoogleUser.id = (user?.uid)!
                // Sign in buttons
                self.gmailLbl.isHidden = true
                self.googleSignInBtn.isHidden = true
                // Game Buttons
                self.welcomeUserLbl.isHidden = false
                self.signOut.isEnabled = true
                self.highScoreBtn.isEnabled = true
                self.guessFrequencyBtn.isHidden = false
                self.guessFrequencyBtn.isEnabled = true
                self.GuessEqBtn.isHidden = false
                self.GuessEqBtn.isEnabled = true
                self.guessFrequencyLbl.isHidden = false
                self.guessEqLbl.isHidden = false
                self.guessFreqLogo.isHidden = false
                self.guessEqLogo.isHidden = false
                self.welcomeUserLbl.text = "Welcome \(currentGoogleUser.displayName)!"

            } else {
                // Sign in buttons
                self.gmailLbl.isHidden = false
                self.googleSignInBtn.isHidden = false
                // Game Buttons
                self.welcomeUserLbl.isHidden = true
                self.signOut.isEnabled = false
                self.highScoreBtn.isEnabled = false
                self.guessFrequencyBtn.isHidden = true
                self.guessFrequencyBtn.isEnabled = false
                self.GuessEqBtn.isHidden = true
                self.GuessEqBtn.isEnabled = false
                self.guessFrequencyLbl.isHidden = true
                self.guessEqLbl.isHidden = true
                self.guessFreqLogo.isHidden = true
                self.guessEqLogo.isHidden = true
            }
        }
    }

    @IBAction func googleSignInBtn(_ sender: Any) {
          GIDSignIn.sharedInstance().signIn()
    }

    @IBAction func signOutAction(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        do {
            try FIRAuth.auth()?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        checkLoggedInStatus()
    }
    
 
}

