//
//  PLItem.swift
//  slsPlayer
//
//  Created by aobskl on 7/4/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Foundation

@objc enum PlayMode : UInt {
    case None
    case Playing
    case Paused
}

///////////////////////////////////////////////////////////

final class PLItem : NSObject, /*NSCopying,*/ Comparable {
    // Make all elements value-types, better for struct...
    //    dynamic
    var url:String // keeps absolutestring
    
//    dynamic
    var title:String?
    
    var artist:String?
    var album:String?
    
//    dynamic
    var duration:Double
    
    //    dynamic
    //    var playMode:PlayMode = .None
    
    var counter:Int = 0
    //    var index:Int = PLItem.nilIndex
    
    static let ntfUpdated = "ntfPLItemUpdated"
    static let keyType = String(PLItem.self)
    
    init(url:String, title:String?=nil, artist:String?=nil, album:String?=nil, duration:Double?=nil) {
        self.url = url;
        self.title = title;
        self.album = album;
        self.duration = duration ?? 0.0;
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let item:PLItem = PLItem(url: url, title: title, artist: artist, album: album, duration: duration)
        
        return item
    }
    
    func updateFromSource() {
        //        if (url.isFileReferenceURL()) {
        //@todo: parse file and
        //        }
    }
}

func <(lhs: PLItem, rhs: PLItem) -> Bool {
    return lhs.url < rhs.url
}

func ==(lhs: PLItem, rhs: PLItem) -> Bool {
    return lhs.url == rhs.url
}


//class PLItemObject: NSObject {
//    let item:PLItem!
//
//    init(item:PLItem) {
//        self.item = item
//    }
//}

///////////////////////////////////////////////////////////
