//
//  PlayerUI.swift
//  slsPlayer
//
//  Created by aobskl on 6/6/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Cocoa

class PlayerUI:WindowedUI {
    
    let player = AVFPlayer()
    var stepTimer:NSTimer?
    
    let vtitle = NSView()
    let vtime = NSView()
    let vbuttons = NSView()
        
    static let tag_txttitle:Int = Utils.newTag()
    static let tag_txttime:Int = Utils.newTag()
    static let tag_txtdur:Int = Utils.newTag()
    static let tag_sldtime:Int = Utils.newTag()
    static let tag_btnplay:Int = Utils.newTag()
    static let tag_btnprev:Int = Utils.newTag()
    static let tag_btnnext:Int = Utils.newTag()
    static let tag_sldVolume:Int = Utils.newTag()
    
    static let txt_na = Const.textPlaceholder
    static let txt_play = " > "
    static let txt_pause = " = "
    
    override init() {
        super.init()
    }
    
    func newReadOnlyTextField() -> NSTextField {
        let tf = NSTextField()
        tf.bezeled = false
        tf.editable = false
        tf.selectable = false
        tf.drawsBackground = false
        tf.controlSize = .SmallControlSize
        tf.alignment = .Center
        tf.stringValue = PlayerUI.txt_na
        return tf
    }
    
    func newLinearSlider() -> NSSlider {
        let ret = NSSlider()
        ret.sliderType = .LinearSlider
        ret.minValue = 0.0
        ret.maxValue = 1.0
        ret.doubleValue = 0.0
        ret.target = self
        ret.action = #selector(action_sld)
        return ret
    }
        
    func initVtitle() {
        let txttitle = newReadOnlyTextField()
        
        txttitle.tag = PlayerUI.tag_txttitle
        
        vtitle.addSubview(txttitle)
        
        //layout:
//        tf.bindFrameToSuperviewBounds()
//        vtitle.bindFrameToSuperviewBounds()
        var size = Utils.getSysTextSize()
        size.height += 2
        
        Utils.makeLayout([
            "V:|-0-[txttitle(>=\(size.height))]-0-|",
//            "V:|-0-[txttitle(<=100)]-0-|",
            "H:|-0-[txttitle]-0-|",
            ], views: ["txttitle":txttitle])
    }
    
    func initVtime() {
        let txttime = newReadOnlyTextField()
        let txtdur = newReadOnlyTextField()
        txttime.tag = PlayerUI.tag_txttime
        txtdur.tag = PlayerUI.tag_txtdur
        
        let sldtime = newLinearSlider()
        sldtime.tag = PlayerUI.tag_sldtime
        
        let views = ["txttime":txttime, "sldtime":sldtime, "txtdur":txtdur]
        for (_,view) in views {vtime.addSubview(view);}
        
        var size = Utils.getSysTextSize("00:00:00")
        size.width += 2
        size.height += 2
        
        Utils.makeLayout([
            "H:|-1-[txttime(\(size.width))]-1-[sldtime(>=100)]-1-[txtdur(\(size.width))]-1-|",
            "V:|-0-[txttime(\(size.height))]-0-|",
            "V:|-0-[sldtime]-0-|",
            "V:|-0-[txtdur(\(size.height))]-0-|",
            ],views: views)
    }
    
    func initVbuttons() {
        let btnprev = newMomentaryButton()
        let btnnext = newMomentaryButton()
        let btnplay = newMomentaryButton()
        let sldvolume = newLinearSlider()
        
        btnprev.title = "<<"
        btnnext.title = ">>"
        btnplay.title = PlayerUI.txt_play
        
        btnprev.tag = PlayerUI.tag_btnprev
        btnnext.tag = PlayerUI.tag_btnnext
        btnplay.tag = PlayerUI.tag_btnplay
        sldvolume.tag = PlayerUI.tag_sldVolume
        
        sldvolume.doubleValue = player.volume
        
        let views = ["btnprev":btnprev, "btnnext":btnnext, "btnplay":btnplay, "sldvolume":sldvolume]
        for (_,view) in views {vbuttons.addSubview(view);}
        
        Utils.makeLayout([
            "H:|-1-[btnprev(30)]-1-[btnnext(30)]-1-[btnplay(40)]-1-[sldvolume(>=50)]-1-|",
            "V:|-0-[btnprev(20)]-0-|",
            "V:|-0-[btnnext(20)]-0-|",
            "V:|-0-[btnplay(20)]-0-|",
            "V:|-0-[sldvolume]-0-|",
            ],views: views)
    }
    
    override func initComponents() {
        super.initComponents()
        initVtitle()
        initVtime()
        initVbuttons()
    }
    
    override func initWindow() {
        super.initWindow()
        
        let views = ["vtitle":vtitle, "vtime": vtime, "vbuttons": vbuttons]
        for (_,view) in views {window.contentView!.addSubview(view);}
        
        Utils.makeLayout([
            "H:|-0-[vtitle]-0-|",
            "H:|-0-[vtime]-0-|",
            "H:|-0-[vbuttons]-0-|",
            "V:|-0-[vtitle]-0-[vtime]-0-[vbuttons]-0-|",
            ], views: views);
        
        let csize = NSMakeSize(300, 100)
        //        window.contentMinSize = csize
        window.setContentSize(csize)
    }
    
    func getViewWithTag<T>(tag:Int, type:T.Type) -> T? {
        return self.window.contentView!.viewWithTag(tag) as? T ;
    }
    
    private weak
    var _item:PLItem? = nil
    
    var item:PLItem?  {
        get {
            return _item
        }
        set(value) {
            let err = player.setItem(value);
            if err != nil {
                _item = nil
                return
            }
            _item = value
    //        let ret:PLItem?
            
            if value == nil {
    //            ret = nil
                getViewWithTag(PlayerUI.tag_txttitle, type:NSTextField.self)!.stringValue = PlayerUI.txt_na
                getViewWithTag(PlayerUI.tag_txttime, type:NSTextField.self)!.stringValue = PlayerUI.txt_na
                getViewWithTag(PlayerUI.tag_txtdur, type:NSTextField.self)!.stringValue = PlayerUI.txt_na
            } else {
    //            ret = item
                getViewWithTag(PlayerUI.tag_txttitle, type:NSTextField.self)!.stringValue = (item?.title ?? "") as String
                getViewWithTag(PlayerUI.tag_txttime, type:NSTextField.self)!.stringValue =
                    Utils.getTimeString(0)
                getViewWithTag(PlayerUI.tag_txtdur, type:NSTextField.self)!.stringValue =
                    Utils.getTimeString(Int(player.duration))
                value!.duration =  player.duration
            }
            getViewWithTag(PlayerUI.tag_sldtime, type:NSSlider.self)!.doubleValue = 0
            
            play(isPlay: value != nil)
            
    //        return ret
        }
    }
    func play(isPlay isPlay:Bool) {
        var isPause = !isPlay
        if isPlay {
            isPause = !player.play()
        } else {
            player.pause()
        }
        //@TODO: pause resume stepper
        if isPause {
            getViewWithTag(PlayerUI.tag_btnplay, type:NSButton.self)?.title = PlayerUI.txt_play
            stepTimerSS(isStop: true)
        } else {
            getViewWithTag(PlayerUI.tag_btnplay, type:NSButton.self)?.title = PlayerUI.txt_pause
            stepTimerSS()
        }
    }
    
    func action_stepTimer(sender:AnyObject) {
        getViewWithTag(PlayerUI.tag_txttime, type:NSTextField.self)?.stringValue =
            Utils.getTimeString(Int(player.currentTime))
        if player.duration > 0 {
            getViewWithTag(PlayerUI.tag_sldtime, type:NSSlider.self)?.doubleValue = player.currentTime/player.duration
        }
    }
    
    func stepTimerSS(isStop isStop:Bool = false) {
        stepTimer?.invalidate()
        stepTimer = nil
        if !isStop {
            stepTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(action_stepTimer), userInfo: nil, repeats: true)
        }
    }
    
    func action_sld(sender:AnyObject) {
        let slider = sender as! NSSlider
        if slider.tag == PlayerUI.tag_sldtime {
            guard player.duration > 0 else {
                return
            }
            let sldTime = getViewWithTag(PlayerUI.tag_sldtime, type:NSSlider.self)!
            assert(sender as! NSObject === sldTime, "sldTimeValueChanged-> sender != sldTime")
            guard let event = sender.window!.currentEvent else {
                Utils.warn("Could not find event for sldValueChanged")
                return
            }
            let etype:NSEventType = event.type
            if (etype == .LeftMouseDown || etype == .LeftMouseDragged || etype == .ScrollWheel) {
                let targetVal = sldTime.doubleValue * player.duration
                if abs(targetVal - player.currentTime) > 0.2 {
                    player.currentTime = targetVal
                    getViewWithTag(PlayerUI.tag_txttime, type:NSTextField.self)!.stringValue =
                        Utils.getTimeString(Int(player.currentTime))
                    
                }
            }
        } else if slider.tag == PlayerUI.tag_sldVolume {
            let sld = getViewWithTag(PlayerUI.tag_sldVolume, type:NSSlider.self)!
            let val = sld.doubleValue
            player.volume = val
        } else {
            Utils.warn("Unhandled slider action for tag:\(slider.tag)")
        }
    }
    
    override
    func action_btn(sender:AnyObject) {
        let btn = sender as! NSButton
        if btn.tag == PlayerUI.tag_btnplay {
            play(isPlay: !player.isPlaying())
        } else if btn.tag == PlayerUI.tag_btnnext {
            sendEvent(Notifications.itemSelect.rawValue, info: [Notifications.itemSelect.rawValue:Notifications.itemSelectNext.rawValue])
        } else if btn.tag == PlayerUI.tag_btnprev {
            sendEvent(Notifications.itemSelect.rawValue, info: [Notifications.itemSelect.rawValue:Notifications.itemSelectPrev.rawValue])
        } else {
            Utils.warn("Unhandled button action for tag:\(btn.tag)")
        }
        
        super.action_btn(sender)
    }
    
    override func initEvents() {
        observe(Notifications.itemSelected.rawValue) { [weak self] notif in
            guard let item = notif.userInfo?[PLItem.keyType] as? PLItem else {
                return
            }
            self?.item = item
        }
        
        super.initEvents()
    }
    
    override func uninitEvents() {
        
        super.uninitEvents()
    }
}

