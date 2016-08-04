//
//  CommonWindowedUI.swift
//  slsPlayer
//
//  Created by basakil on 6/7/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Cocoa

class WindowedUI: NSObject {
    let window:NSWindow = NSWindow(contentRect: NSMakeRect(100, 100, 400, 500),
                                   styleMask: NSTitledWindowMask|NSMiniaturizableWindowMask|NSClosableWindowMask|NSResizableWindowMask,
                                   backing: NSBackingStoreType.Buffered,
                                   defer: false)
    
    var notifs:[NSObjectProtocol] = [NSObjectProtocol]()
    
    override init() {
        super.init()
        initComponents()
        initWindow()
        initEvents()
    }
    
    deinit {
        uninitEvents()
        uninitWindow()
        uninitComponents()
    }
    
    func initComponents() {
        
    }
    
    func uninitComponents() {
        
    }
    
    func initWindow() {
        
    }
    
    func uninitWindow() {
        
    }
    
    func observe(notificationName: String, block: (NSNotification) -> ()) {
        let notif = NSNotificationCenter.defaultCenter().addObserverForName(notificationName, object: nil, queue: nil, usingBlock: block)
        notifs.append(notif)
    }
    
    func initEvents() {
        
    }
    
    func uninitEvents() {
        let center = NSNotificationCenter.defaultCenter()
        for notif in notifs {
            center.removeObserver(notif)
        }
        notifs.removeAll()
    }
    
    func sendEvent(name:String, info:[NSObject: AnyObject]?) {
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(name, object: self, userInfo: info)
    }
    
    func setVisible(isVisible:Bool) {
        //        window.setIsVisible(isVisible);
        if (isVisible) {
            window.makeKeyAndOrderFront(nil)
        } else {
            window.close()
        }
        //        window.sho
    }
    
    func isVisible() -> Bool {
        return window.visible;
    }
    
    func newMomentaryButton(tag tag:Int? = nil, title:String? = nil) -> NSButton {
        return Utils.newMomentaryButton(tag:tag, title:title, target:self, sel:#selector(action_btn))
    }
    
    func action_btn(sender:AnyObject) {
        
    }
}
