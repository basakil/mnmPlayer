//
//  ICCP.swift
//  slsPlayer
//
//  Created by basakil on 7/4/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Cocoa

protocol ICCP {
    func ccp_cut(pboard:NSPasteboard) -> Bool
    func ccp_copy(pboard:NSPasteboard) -> Bool
    func ccp_paste(pboard:NSPasteboard, toPos:Int?) -> Bool
    func ccp_delete() -> Bool
    func ccp_selectAll() -> Bool
}