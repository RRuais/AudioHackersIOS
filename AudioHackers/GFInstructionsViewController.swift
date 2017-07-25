//
//  GFInstructionsViewController.swift
//  AudioHackers
//
//  Created by Rich Ruais on 6/6/17.
//  Copyright © 2017 Rich Ruais. All rights reserved.
//

import UIKit
import Firebase

class GFInstructionsViewController: UIViewController {

    @IBOutlet weak var backBtn: UIBarButtonItem!
    
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

        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    

}
