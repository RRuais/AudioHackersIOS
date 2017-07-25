//
//  GuessEqHighScoreViewController.swift
//  AudioHackers
//
//  Created by Rich Ruais on 6/8/17.
//  Copyright © 2017 Rich Ruais. All rights reserved.
//


import UIKit
import Firebase



class GuessEqHighScoreViewController: UIViewController {
    
    let userDefaults = Foundation.UserDefaults.standard
    let gc = GameController()
    var scores = [[String: String]]()
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionLbl: UILabel!
    @IBOutlet weak var adView: UIView!
    
    var bannerView: GADBannerView!
    let request = GADRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/6300978111"
        bannerView.rootViewController = self
        bannerView.load(request)
        adView.addSubview(bannerView)

        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.clear
        tableView.layer.cornerRadius = 15
        indicator = activityIndicator
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        indicatorView.isHidden = true
        indicator.isHidden = true
        connectionLbl.isHidden = true
        checkInternetConnection()
    }
    
    func checkInternetConnection() {
        if Connectivity.isConnectedToInternet() {
            print("Internet is available.")
            connectionLbl.isHidden = true
            tableView.isHidden = false
            getHighScores()
        } else {
            print("No Internet")
            connectionLbl.isHidden = false
            tableView.isHidden = true
            indicatorView.isHidden = false
            indicator.isHidden = false
        }
    }

    
    func getHighScores() {
        connectionLbl.isHidden = true
        indicatorView.isHidden = false
        indicator.isHidden = false
        indicator.startAnimating()
        gc.retrieveHighScores(path: "GuessEqHighScores", pathForDefaults: "currentEqHighScores")
        if let value = userDefaults.array(forKey: "currentEqHighScores") {
            scores = value as! [[String : String]]
            let newScores = sortScores(arr: scores)
            scores = newScores
            indicatorView.isHidden = true
            indicator.isHidden = true
            indicator.stopAnimating()
            tableView.reloadData()
        }
    }
    
    func sortScores(arr: [[String : String]]) -> [[String : String]] {
        var oldArr = arr
        var newArr = [[String : String]]()
        while oldArr.count > 0 {
            let max = findMax(arr: oldArr)
            newArr.append(oldArr[max])
            oldArr.remove(at: max)
        }
        return newArr
    }
    
    func findMax(arr: [[String : String]]) -> Int {
        let max = arr[0]["percentage"]
        var floatMax = Float(max!)
        var maxIndex = 0
        for index in 0..<arr.count {
            let temp = Float(arr[index]["percentage"]!)
            if temp! > floatMax! {
                floatMax = temp
                maxIndex = index
            }
        }
        return maxIndex
    }
    
    
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
}

extension GuessEqHighScoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let correctLbl = cell.viewWithTag(1) as! UILabel
        correctLbl.text = scores[indexPath.row]["numberCorrect"]!
        let incorrectLbl = cell.viewWithTag(2) as! UILabel
        incorrectLbl.text = scores[indexPath.row]["numberIncorrect"]!
        let roundsLbl = cell.viewWithTag(3) as! UILabel
        roundsLbl.text = scores[indexPath.row]["round"]!
        
        let percentageLbl = cell.viewWithTag(4) as! UILabel
        let percentageString = scores[indexPath.row]["percentage"]!
        
        let percentageRounded = roundf(Float(percentageString)!)
        percentageLbl.text = String(percentageRounded)
        
        let numberIndexLbl = cell.viewWithTag(5) as! UILabel
        numberIndexLbl.text = String(indexPath.row + 1)
        let progressview = cell.viewWithTag(6) as! ProgressBarView
        progressview.layer.cornerRadius = 10
        
        // Draw Percentage Bar
        var newCGFloat = Float()
        let width = Float(progressview.bounds.width)
        let percentage = percentageRounded / Float(100)
        newCGFloat = Float(percentage) * width
        progressview.progress = CGFloat(percentage)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let score = scores[indexPath.row]
            print(score)
            scores.remove(at: indexPath.row)
            gc.deleteScore(scoreToDelete: score, path: "GuessEqHighScores")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}



