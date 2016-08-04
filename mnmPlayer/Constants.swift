//
//  Notifications.swift
//  slsPlayer
//
//  Created by basakil on 6/11/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Foundation

enum Notifications:String {
    
    case itemSelected = "itemSelected"
    case itemStopped = "itemStopped"
    case itemSelect = "itemSelect"
        case itemSelectNext = "itemSelectNext"
        case itemSelectPrev = "itemSelectPrev"
    
}

class Const {
    static let textPlaceholder = "---"
    
    static let plExt = "m3u"
    private
    static var _plExtRe: NSRegularExpression? = nil
    static var plExtRe: NSRegularExpression? {
        get {
            if _plExtRe == nil {
                do {
                    try _plExtRe = NSRegularExpression(pattern: "(^.*)\\.\(Const.plExt)[8]?$", options: .CaseInsensitive)
                } catch let err {
                    Utils.error("Error construction regex: \(err)")
                    _plExtRe = nil
                }
            }
            return _plExtRe
        }
    }
}

