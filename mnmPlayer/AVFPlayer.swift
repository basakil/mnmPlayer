//
//  AVFPlayer.swift
//  slsPlayer
//
//  Created by basakil on 5/17/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import AVFoundation

enum PlayerError: ErrorType {
    case InitURL
    case InitPlayer
}

//@TODO make a player proto & conform (factorisation?)
class AVFPlayer : NSObject {
//    var player:AVAudioPlayer? = nil
    var player:AVPlayer? = nil
    var item:PLItem? = nil
    var vpui:VideoPlayerUI? = nil
    
    override init() {
//        do {
////            var error:NSError?
////            let url1 = NSURL.fileURLWithPath("/Users/aobskl/temp/music1.mp3");
//            let url1 = NSURL(string:"file:///Users/aobskl/temp/music1.mp3")!;
////            let url1 = NSURL(string:"http://root:password@site1.com:8090/pages/page1.jsp?attr1=val1&attr2=val2#anchor1")!;
//            try player = AVAudioPlayer(contentsOfURL: url1)
////            player!.numberOfLoops = -1
//            player!.prepareToPlay()
//            let url1str = url1.absoluteString
//            print("url1:\(url1.absoluteString) isFileRef=\(url1.isFileReferenceURL())")
//            
//            let url2 = NSURL(string: url1str)
//            print("url2:\(url2!.absoluteString)")
//        } catch {
//            player = nil
//            print("Error: could not initialize player..")
//        }
////        player!.play()
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(actDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(actDidFinishPlaying(_:)), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: nil)

    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemFailedToPlayToEndTimeNotification, object: nil)
        
        deletePlayer()
    }
    
    func play() -> Bool {
        guard let player = self.player else {
            return false
        }
        player.play()
        if player.currentItem!.asset.tracksWithMediaType(AVMediaTypeVideo).count > 0 {
            if vpui == nil {
                vpui = VideoPlayerUI()
            }
            vpui?.player = player
            vpui?.setVisible(true)
        } else {
            if vpui != nil {
                vpui!.player = nil
                vpui = nil
            }
        }
        return player.error == nil
    }
    
    func pause() {
        player?.pause()
        // make a timer and stop the player if necessary..
    }
    
    func isPlaying() -> Bool {
        if (player?.rate != 0 && player?.error == nil) {
            return true
        }
        return false
    }
    
    private func newPlayer(url:NSURL) throws -> AVPlayer {
        let playerItem = AVPlayerItem(URL: url)
        player = AVPlayer(playerItem: playerItem)
        player!.volume = Float(volume)
        
        // refresh the new players listeners with the old one...
        isPeriodicTimerRunning = _isPeriodicTimerRunning
        
        return player!
    }
    
    private func deletePlayer() {
        if vpui != nil {
            vpui!.player = nil
            vpui = nil
        }
        if player != nil {
            isPeriodicTimerRunning = false
            player!.pause()
            player!.replaceCurrentItemWithPlayerItem(nil)
            player = nil
        }
    }
    
    func setItem(item:PLItem? = nil, isUpdateFields:Bool = false) -> PlayerError? {
        deletePlayer()
        
        self.item = item
        
        if item != nil {
            guard let url = NSURL(string:item!.url) else {
                return PlayerError.InitURL
            }
            do {
                try newPlayer(url)
            } catch (let exc){
                print("Error: could not initialize player: \(exc)")
                player = nil
                return PlayerError.InitPlayer
            }
            if isUpdateFields {
                item!.duration = player!.currentItem?.duration.seconds ?? item!.duration
                //@TODO: read/update some more properties
            }
        }
        
        return nil
    }
    
    var currentTime:Double {
        get {
            return player?.currentItem?.currentTime().seconds ?? 0
        }
        
        set(val) {
            player?.currentItem?.seekToTime(CMTime(seconds: val, preferredTimescale: 1000))
        }
    }
    
    var duration:Double {
        get {
            return player?.currentItem?.duration.seconds ?? 0
        }
    }
    
    private var _volume:Double = 0.5
    
    var volume:Double {
        get {
            return _volume
        }
        set(val) {
            guard val != _volume && val <= 1 && val >= 0 else {
                return
            }
            _volume = val
            player?.volume = Float(_volume)
        }
    }
    
    func actDidFinishPlaying(note: NSNotification) {
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(Notifications.itemStopped.rawValue,
                                    object: self,
                                    userInfo: [PLItem.keyType:self.item!])
    }
    
    func actPeriodicTimer(time: CMTime) {
//        Swift.print("periodic: \(time.value)")
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(Notifications.playerPeriodicEvent.rawValue,
                                    object: self,
                                    userInfo: [PLItem.keyType:self.item!])
        
    }
    
    var _periodicTimer:AnyObject? = nil
    var _isPeriodicTimerRunning:Bool = false
    var isPeriodicTimerRunning:Bool { //maybe called without a player object...
        get {
            return _periodicTimer != nil
        }
        set (value) {
            if !value {
//                _isPeriodicTimerRunning = false
                guard _periodicTimer != nil else {
                    return
                }
//                assert(player != nil, "cannot stop timer event for a nil player!!")
                player?.removeTimeObserver(_periodicTimer!)
                _periodicTimer = nil
            } else {
//                _isPeriodicTimerRunning = true
                guard _periodicTimer == nil else {
                    return
                }
//                assert(player != nil, "cannot start timer event for a nil player!!")
                _periodicTimer = player?.addPeriodicTimeObserverForInterval(CMTime(value: 500, timescale: 1000), queue: nil, usingBlock: actPeriodicTimer(_:))
            }
        }
    }
    
} // class AVFPlayer

///////////////////////////////////////////

extension AVFPlayer : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer,
                                       successfully flag: Bool) {
        
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(Notifications.itemStopped.rawValue,
                                    object: self,
                                    userInfo: [PLItem.keyType:self.item!])
        
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer,
                                          error: NSError?) {
        //@TODO: nothing on error?
    }
}


