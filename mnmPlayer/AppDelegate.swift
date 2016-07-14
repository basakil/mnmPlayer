//
//  AppDelegate.swift
//  mnmPlayer
//
//  Created by aobskl on 7/14/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Cocoa

//@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let playListUI = PlayListUI()
    let playerUI = PlayerUI()
    
    override init() {
        super.init()
        
        initUI()
    }
    
    func initMainMenu() {
        let app = NSApplication.sharedApplication()
        
        let menubar = NSMenu()
        let appMenuItem = NSMenuItem()
        menubar.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        let quitMenuItem = NSMenuItem(title: "Quit \(NSProcessInfo.processInfo().processName)",
                                      action:#selector(app.terminate),
                                      keyEquivalent: "q")
        appMenu.addItem(quitMenuItem)
        appMenuItem.submenu = appMenu
        
        let editMenu = NSMenu(title: "Edit")
        let selAllMenuItem = NSMenuItem(title: "Select All",
                                        action:#selector(self.actionSelectAll(_:)),
                                        keyEquivalent: "a")
        editMenu.addItem(selAllMenuItem)
        
        let delSelMenuItem = NSMenuItem(title: "Delete Selected",
                                        action:#selector(self.actionDeleteSelected(_:)),
                                        keyEquivalent: "\u{8}")
        editMenu.addItem(delSelMenuItem)
        
        let editMenuItem = NSMenuItem()
        editMenuItem.submenu = editMenu
        menubar.addItem(editMenuItem)
        
        
        app.mainMenu = menubar
    }
    
    func initUI() {
        
        initMainMenu()
    }
    
    var playList:PlayList {
        get {
            return playListUI.pl
        }
    }
    
    func actionSelectAll(sender:AnyObject) {
        //        playListUI.focus
        playList.ccp_selectAll()
    }
    
    func actionDeleteSelected(sender:AnyObject) {
        playList.ccp_delete()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        //        initMainMenu()
        //        player.play()
        playListUI.setVisible(true)
        playerUI.setVisible(true)
        
        //        mWindow.orderFrontRegardless()
        //        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(app: NSApplication) -> Bool {
        return true
    }
}


/*
 controller = ViewController()
 let content = newWindow!.contentView as NSView
 let view = controller!.view
 content.addSubview(view)
 
 newWindow!.makeKeyAndOrderFront(nil)
 */

/*
 import Cocoa
 
 class ViewController : NSViewController {
 override func loadView() {
 let view = NSView(frame: NSMakeRect(0,0,100,100))
 view.wantsLayer = true
 view.layer?.borderWidth = 2
 view.layer?.borderColor = NSColor.redColor().CGColor
 self.view = view
 }
 }
 */