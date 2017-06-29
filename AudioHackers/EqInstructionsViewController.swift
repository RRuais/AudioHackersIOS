//
//  EqInstructionsViewController.swift
//  AudioHackers
//
//  Created by Rich Ruais on 6/10/17.
//  Copyright © 2017 Rich Ruais. All rights reserved.
//

import UIKit

class EqInstructionsViewController: UIViewController {

    @IBOutlet weak var backBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

}
