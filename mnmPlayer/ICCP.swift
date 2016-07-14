//
//  ICCP.swift
//  slsPlayer
//
//  Created by aobskl on 7/4/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Foundation

protocol ICCP {
    func ccp_cut() -> Bool
    func ccp_copy() -> Bool
    func ccp_paste() -> Bool
    func ccp_delete() -> Bool
    func ccp_selectAll() -> Bool
}