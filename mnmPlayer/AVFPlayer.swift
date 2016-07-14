//
//  AVFPlayer.swift
//  slsPlayer
//
//  Created by aobskl on 5/17/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import AVFoundation

enum PlayerError: ErrorType {
    case InitURL
    case InitPlayer
}

//@TODO make a player proto & conform (factorisation?)
class AVFPlayer : NSObject {
    var player:AVAudioPlayer? = nil
    var item:PLItem? = nil
    
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
    }
    
    func play() -> Bool {
        return player?.play() ?? false
    }
    
    func pause() {
        player?.pause()
        // make a timer and stop the player if necessary..
    }
    
    func isPlaying() -> Bool {
        return player?.playing ?? false
    }
    
    private func newPlayer(url:NSURL) throws -> AVAudioPlayer {
        let player = try AVAudioPlayer(contentsOfURL: url)
        player.volume = Float(volume)
        player.delegate = self
        
        return player
    }
    
    func setItem(item:PLItem? = nil, isUpdateFields:Bool = false) -> PlayerError? {
        
        if player != nil {
            player!.stop()
            player = nil
        }
        
        self.item = item
        
        if item != nil {
            guard let url = NSURL(string:item!.url) else {
                return PlayerError.InitURL
            }
            do {
                try player = newPlayer(url)
            } catch (let exc){
                print("Error: could not initialize player: \(exc)")
                player = nil
                return PlayerError.InitPlayer
            }
            if isUpdateFields {
                item!.duration = player!.duration
                //@TODO: read/update some more properties
            }
        }
        
        return nil
    }
    
    var currentTime:Double {
        get {
            return player?.currentTime ?? 0
        }
        
        set(val) {
            player?.currentTime = val
        }
    }
    
    var duration:Double {
        get {
            return player?.duration ?? 0
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


