//
//  VideoPlayerUI.swift
//  mnmPlayer
//
//  Created by basakil on 8/4/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

class VideoPlayerUI: WindowedUI {
    let playerView:AVPlayerView = AVPlayerView(frame: NSRect(x: 0, y: 0, width: 320, height: 180))
    
    override
    func initWindow() {
        super.initWindow()
        
        initPlayerView()
        
    }
    
    override func uninitWindow() {
        player = nil
    }
    
    func initPlayerView() {
        playerView.controlsStyle = AVPlayerViewControlsStyle.Default
        playerView.showsFullScreenToggleButton = true
//        playerView.sh
        
        let cv = window.contentView!
        
        let views = ["playerView":playerView]
        for (_,view) in views {cv.addSubview(view);}
        
        Utils.makeLayout([
            "H:|-1-[playerView]-1-|",
            "V:|-1-[playerView]-1-|",
            ],views: views)
    }
    
    override func setVisible(isVisible: Bool) {
        if (isVisible) {
//            let cv = window.contentView!
//            if cv.bounds.width <= 10 || cv.bounds.height <= 10 {
//                cv.setFrameSize(NSSize(width: 322, height: 182))
                let csize = NSMakeSize(322, 182)
                //        window.contentMinSize = csize
                window.setContentSize(csize)
//            }
        }
        super.setVisible(isVisible)
    }
    
    var player:AVPlayer? {
        get {
            return playerView.player
        }
        set(value) {
            playerView.player = value
        }
    }
    
    func show(player:AVPlayer) {
        playerView.player = player
        

        
        setVisible(true)
    }
}
