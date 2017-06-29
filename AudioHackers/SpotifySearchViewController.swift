//
//  SpotifySearchViewController.swift
//  AudioHackers
//
//  Created by Rich Ruais on 6/6/17.
//  Copyright © 2017 Rich Ruais. All rights reserved.
//

import UIKit
import Alamofire

struct Track {
    var artist: String!
    var songTitle: String!
    var largeAlbumImage: String!
    var smallAlbumImage: String!
    var albumName: String!
    var uri: String!
    var duration: Int!
    var previewURL: String!
}


class SpotifySearchViewController: UIViewController, UISearchBarDelegate, UITextViewDelegate {

    var tracksLoaded = [Track]()
    let eqGuessVC = EQGuessViewController()
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var defaultTrackLbl: UIButton!
    @IBOutlet weak var playPauseBtnLbl: UIButton!
    @IBOutlet weak var connectionLbl: UILabel!
    
    let playImage = UIImage(named: "Play")
    let pauseImage = UIImage(named: "Pause")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultTrackLbl.layer.cornerRadius = 7
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = activityIndicator
        searchBar.delegate = self
        searchBar.keyboardAppearance = .dark
        
        indicator = activityIndicator
        indicatorView.isHidden = true
        indicator.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        indicatorView.isHidden = true
        indicator.isHidden = true
        connectionLbl.isHidden = true
        
        if AudioPlayerController.sharedInstance.isPlaying {
            playPauseBtnLbl.setImage(pauseImage , for: .normal)
        } else {
            playPauseBtnLbl.setImage(playImage, for: .normal)
        }
        checkInternetConnection()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func checkInternetConnection() {
        if Connectivity.isConnectedToInternet() {
            print("Internet is available.")
            connectionLbl.isHidden = true
            tableView.isHidden = false
            indicatorView.isHidden = true
            indicator.isHidden = true
            searchBar.isUserInteractionEnabled = true
        } else {
            print("No Internet")
            connectionLbl.isHidden = false
            tableView.isHidden = true
            indicatorView.isHidden = false
            
            searchBar.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func playPause(_ sender: Any) {
        AudioPlayerController.sharedInstance.playPause()
        if AudioPlayerController.sharedInstance.isPlaying {
            playPauseBtnLbl.setImage(pauseImage , for: .normal)
        } else {
            playPauseBtnLbl.setImage(playImage , for: .normal)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchBar.resignFirstResponder()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tracksLoaded.removeAll()
        tableView.reloadData()
        indicatorView.isHidden = false
        indicator.isHidden = false
        indicator.startAnimating()
        
        
        //        scrollToRefreshCount = 10
        let keywords = searchBar.text
        print(keywords!)
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")
//        let currentSearchWords = finalKeywords!
        let searchTrackURL = "https://itunes.apple.com/search?term=\(finalKeywords!)&entity=song"
        searchTrack(url: searchTrackURL)
        searchBar.resignFirstResponder()
    }


    func searchTrack(url: String) {
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
          
            self.parseTrackData(JSONData: response.data!)
           
        })
    }
    
    
    
    func parseTrackData(JSONData : Data) {
      
        var tempArr = [Track]()
        tempArr = parseTrackHelper(JSONData: JSONData)
        print(tempArr)
        for i in 0..<tempArr.count {
            tracksLoaded.append(tempArr[i])
        }
        print(tracksLoaded)
        indicatorView.isHidden = true
        indicator.isHidden = true
        self.indicator.stopAnimating()
        self.tableView.reloadData()
    }
    
    
    func parseTrackHelper(JSONData : Data) -> [Track] {
        var tempArr = [Track]()
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String : AnyObject]
            if let results = readableJSON["results"] as? [[String : Any]] {
                for i in 0..<results.count {
                    if let item = results[i] as? [String : Any] {
                    let artistName = item["artistName"] as! String
                    let songTitle = item["trackName"] as! String
                    let albumName = item["collectionName"] as! String
                    let largeAlbumImage = item["artworkUrl60"] as! String
                    let smallAlbumImage = item["artworkUrl30"] as! String
                    if let previewURL = item["previewUrl"] {
                    let newTrack = Track.init(artist: artistName, songTitle: songTitle, largeAlbumImage: largeAlbumImage, smallAlbumImage: smallAlbumImage, albumName: albumName, uri: "", duration: 0, previewURL: previewURL as! String)
                    tempArr.append(newTrack)
                        }
                }
                }
                
            }
        } catch {
            print(error)
        }
        return tempArr
    }
    
    @IBAction func loadDefaultTrack(_ sender: Any) {
        let firstTrack = URL.init(fileURLWithPath: Bundle.main.path(
            forResource: "mainSong",
            ofType: "wav")!)
        AudioPlayerController.sharedInstance.loadAudioFromURL(url: firstTrack)
        playPauseBtnLbl.setImage(pauseImage , for: .normal)
    }
    
 
    @IBAction func clearSearch(_ sender: UIButton) {
        tracksLoaded.removeAll()
        tableView.reloadData()
    }


}

extension SpotifySearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracksLoaded.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let songLabel = cell.viewWithTag(3) as! UILabel
        songLabel.text = tracksLoaded[indexPath.row].songTitle
        let artistLabel = cell.viewWithTag(2) as! UILabel
        artistLabel.text = tracksLoaded[indexPath.row].artist
        let smallImage = cell.viewWithTag(1) as! UIImageView
        smallImage.layer.cornerRadius = 5
        smallImage.layer.borderWidth = 2
        let smallAlbumUrl = URL(string: tracksLoaded[indexPath.row].smallAlbumImage)
        let smallImageData = NSData(contentsOf: smallAlbumUrl!)
        let smallAlbumImage = UIImage(data: smallImageData! as Data)
        smallImage.image = smallAlbumImage
        return cell
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTrackPreview = tracksLoaded[indexPath.row].previewURL
        AudioPlayerController.sharedInstance.downloadFileFromURL(url: URL(string: tracksLoaded[indexPath.row].previewURL)!)
       
        playPauseBtnLbl.setImage(pauseImage , for: .normal)
    }
    
}
