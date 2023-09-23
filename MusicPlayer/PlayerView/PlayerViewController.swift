//
//  PlayerViewController.swift
//  MusicPlayer
//
//  Created by Hitesh Agarwal on 23/09/23.
//

import UIKit

class PlayerViewController: UIViewController {
 
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songAlbumLabel: UILabel!
    @IBOutlet weak var songDurationLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var volumeDownButton: UIButton!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var volumeUpButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var viewModel = PlayerViewModel()
    var durationTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSongs()
    }
    
    func fetchSongs() {
        viewModel.fetchSongs { isSuccess in
            if isSuccess {
                self.viewModel.playSong(atIndex: 0)
                setupActiveSong()
//                startTimer()
            }
        }
    }
    
    func setupActiveSong() {
        self.songTitleLabel.text = viewModel.songTitle
        self.songArtistLabel.text = viewModel.songArtist
        self.songAlbumLabel.text = viewModel.songAlbum
        self.songDurationLabel.text = viewModel.duration
        self.playPauseButton.setTitle(viewModel.playPauseButtonTitle, for: .normal)
        self.volumeLabel.text = viewModel.curentVolumeInString
    }
    
    @IBAction func volumeDown() {
        viewModel.updateVolume(by: -1)
    }
    
    @IBAction func playPauseSongAction() {
        switch viewModel.currentState {
        case .play:
            stopTimer()
            viewModel.currentState = .pause
        case .pause:
            startTimer()
            viewModel.currentState = .play
        case .none:
            break
        }
    }
    
    @IBAction func skipAction() {
        viewModel.playNextSong()
        setupActiveSong()
    }
    
    @IBAction func volumeUP() {
        viewModel.updateVolume(by: 1)
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.viewModel.currentState == .pause {
                timer.invalidate()
                self.setupActiveSong()
            } else {
                self.viewModel.updateDuration(upSec: 1)
                self.setupActiveSong()
            }
             
        }
//        durationTimer.fire()
    }
    
    func stopTimer() {
    }
}

protocol PlayerViewModelDelegate: AnyObject {
    func playSong()
}

enum PlayPauseEnum {
    case play
    case pause
    case none
}

class PlayerViewModel {
    var songModel = [SongModel]()
    var apiDataManager = PlayerAPIDataManager()
    var activeSongIndex: Int = -1
    var activeSong: SongModel?
    var curentVolume = 50
    var currentState: PlayPauseEnum = .pause
    var currentDuration = 0
    
    var songTitle: String {
        activeSong?.title ?? "--"
    }
    
    var songAlbum: String {
        activeSong?.album ?? "NA"
    }
    
    var songArtist: String {
        activeSong?.artist ?? "NA"
    }
    
    var duration: String {
        //        activeSong?.duration ?? "NA"
        return "\(currentDuration) sec"
    }
    
    var playPauseButtonTitle: String {
        switch currentState {
        case .play:
            return "Pause"
        case .pause:
            return "Play"
        case .none:
            return ""
        } 
    }
    
    var curentVolumeInString: String {
        return "\(curentVolume)"
    }
    
    func playPauseSong(state: PlayPauseEnum) {
        self.currentState = state
    }
    
    func updateVolume(by value: Int) {
        let newValue = curentVolume + value
        if (0...100).contains(newValue) {
            curentVolume = newValue
        }
    }
    
    func fetchSongs(completion: (Bool) -> ()) {
        apiDataManager.getSongsList { songModel in
            self.songModel = songModel
            completion(true)
        }
    }
    
    func playSong(atIndex index: Int) {
        var newActiveSongIndex = index
        if newActiveSongIndex >= songModel.count {
            newActiveSongIndex = 0
        }
        let newActiveSong = songModel[newActiveSongIndex]
        self.activeSongIndex = newActiveSongIndex
        self.activeSong = newActiveSong
    }
    
    func playNextSong() {
        let newSongIndex = activeSongIndex + 1
        if newSongIndex < songModel.count {
            playSong(atIndex: newSongIndex)
        } else {
            playSong(atIndex: 0)
        }
    }
    
    func updateDuration(upSec: Int) {
        let max = 2
        let newCurrentDuration = currentDuration + upSec
        if newCurrentDuration > max {
            playSong(atIndex: activeSongIndex + 1)
            currentDuration = 0
        } else {
            currentDuration = newCurrentDuration
        }
    }
}

class SongModel {
    var songURL = ""
    let title: String
    let artist: String
    let album: String
    let duration: String
    
    init(songURL: String, title: String, artist: String, album: String, duration: String) {
        self.songURL = songURL
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
    }
}

class PlayerAPIDataManager {
    
    var networkManager = NetworManager()
    
    func getSongsList(completion: ([SongModel]) -> ()) {
        
        let songsAPIPath = "ssdds"
        networkManager.getAPI(url: songsAPIPath) { songsList in
            var songsModels = [SongModel]()
            songsModels.append(SongModel(songURL: "ss", title: "T1", artist: "A 1", album: "AL 1", duration: "1 Min"))
            songsModels.append(SongModel(songURL: "ss", title: "T2", artist: "A 2", album: "AL 2", duration: "2 Min"))
            songsModels.append(SongModel(songURL: "ss", title: "T3", artist: "A 3", album: "AL 3", duration: "3 Min"))
            completion(songsModels)
        }
    }
}

class NetworManager {
    
    func getAPI(url: String, completion: ( ([String]) -> ())) {
        var songsResponse = ["url1"]
        completion(songsResponse)
    }
}
