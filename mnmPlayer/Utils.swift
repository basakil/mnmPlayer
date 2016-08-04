//
//  Utils.swift
//  slsPlayer
//
//  Created by basakil on 6/2/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Cocoa

extension NSView {
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            Swift.print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
    
}

extension String {
    func indexOf(string: String) -> String.Index? {
        return rangeOfString(string, options: .LiteralSearch, range: nil, locale: nil)?.startIndex
    }
    
    func firstSub(regex regex:NSRegularExpression) -> String? {
        let matches = regex.matchesInString(self, options: [], range: NSRange(location: 0, length: characters.count))
        if let match = matches.first {
            let range = match.rangeAtIndex(1)
            if let swiftRange = range.rangeForString(self) {
                let sub = self.substringWithRange(swiftRange)
                return sub
            }
        }
        return nil
    }
}

extension NSRange {
    func rangeForString(str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        return str.startIndex.advancedBy(location) ..< str.startIndex.advancedBy(location + length)
    }
}

public class Weak<T: AnyObject> {
    public weak var value : T?
    public init (value: T) {
        self.value = value
    }
}

class Utils {
//    static func getFileListRecursive(path path:NSURL, enum:(NSURL)->Bool) -> Bool {
//
//
//    }
    
    static let t100 = "Lorem ipsum dolor sit amet, Consectetur adipiscing elit, Sed do eiusmod tempor incididunt ut labore "
    static var t100Dict = [CGFloat:CGFloat]() // font-size to t100 width map
    
    static func makeLayout(constraints:[String], views:[String:NSView], options:NSLayoutFormatOptions = []) -> [NSLayoutConstraint] {
        var cs = [NSLayoutConstraint]()
        
        for (_, view) in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        for constraint in constraints {
            cs += NSLayoutConstraint.constraintsWithVisualFormat(constraint, options: options, metrics: nil, views: views)
        }
        
        NSLayoutConstraint.activateConstraints(cs)
        
        return cs
    }
    
    static func getTimeString(totalSeconds:Int,alwaysPutHour:Bool = false) -> String {
        let cstr = UnsafeMutablePointer<Int8>.alloc(12)
        getTimeText(Int32(totalSeconds), cstr, alwaysPutHour)
        let ret = String(CString: cstr, encoding: NSISOLatin1StringEncoding)
        return ret ?? ""
    }
    
    static func indexSet2Ranges(set:NSIndexSet) -> [Range<Int>] {
        var ret = [Range<Int>]()
        var shift = 0
        var start = set.firstIndex
        var end = set.firstIndex
        
        for f1 in set {
            if f1 <= end+1 {
                end = f1
                continue
            }
            let range = Range<Int>(start-shift...end-shift)
            ret.append(range)
            shift += end-start+1
            
            start = f1
            end = f1
        }
        
        //the last remaining..
        let range = Range<Int>(start-shift...end-shift)
        ret.append(range)
        
        return ret
    }
    
    static func getSysTextSize(text:String="System of PYQ", fontSize:CGFloat=NSFont.systemFontSize()) -> NSSize {
        let size = (text as NSString).sizeWithAttributes(
            [NSFontAttributeName:NSFont.systemFontOfSize(fontSize)])
        return size
    }
    
    static func getSysCharsWidth(count:Int, fontSize:CGFloat=NSFont.systemFontSize()) -> CGFloat {
        if t100Dict[fontSize] == nil {
            t100Dict[fontSize] = getSysTextSize(t100, fontSize: fontSize).width
        }
        return t100Dict[fontSize]! * (CGFloat(count)/CGFloat(100.0))
    }
    
    static func performAppMenuAction(window:NSWindow?, modifiers:NSEventModifierFlags, characters: String) {
        //@NOTICE: not tested..
        let newEvent = NSEvent.keyEventWithType(NSEventType.KeyDown,
                                                location: NSMakePoint(0, 0),
                                                modifierFlags: modifiers,
                                                timestamp: NSTimeInterval(),
                                                windowNumber: window!.windowNumber,
                                                context: nil,
                                                characters: characters,
                                                charactersIgnoringModifiers: characters,
                                                isARepeat: false,
                                                keyCode: 0) //??

        let app = NSApplication.sharedApplication()
        app.mainMenu!.performKeyEquivalent(newEvent!)
    }
    
//    static var appSupportURL:NSURL? {
//        get {
//            let fileManager = NSFileManager.defaultManager()
//            let urls = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask) 
//            if let applicationSupportURL = urls.last {
//                do {
//                    try fileManager.createDirectoryAtURL(applicationSupportURL, withIntermediateDirectories: true, attributes: nil)
//                } catch (let err) {
//                    print("Error: cannot create appSupportURL at:\(applicationSupportURL.absoluteString), errr:\(err)");
//                    return nil
//                }
//                return applicationSupportURL
//            }
//            return nil
//        }
//    }
    
    static func getUserFolder(dir:NSSearchPathDirectory, sub:String?) -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(dir, inDomains: .UserDomainMask)
        let appName = NSProcessInfo.processInfo().processName
        if let durl = urls.last {
            var subUrl = NSURL(fileURLWithPath: appName, isDirectory: true, relativeToURL: durl)
            do {
                if sub != nil {
                    subUrl = NSURL(fileURLWithPath: sub!, isDirectory: true, relativeToURL: subUrl)
                }
                try fileManager.createDirectoryAtURL(subUrl, withIntermediateDirectories: true, attributes: nil)
            } catch (let err) {
                print("Error: cannot create URL at:\(durl.absoluteString), errr:\(err)");
                return nil
            }
            return subUrl
        }
        return nil
    }
    
    static let tag_init:Int = 1000
    static var tag_current:Int = tag_init
    static func newTag() -> Int {
        tag_current += 1
        return tag_current
    }
    
    static func newMomentaryButton(tag tag:Int? = nil, title:String? = nil, target:AnyObject? = nil, sel:Selector? = nil) -> NSButton {
        
        let ret = NSButton()
        ret.setButtonType(.MomentaryPushInButton)
        
        if (tag != nil) {
            ret.tag = tag!
        }
        
        if (title != nil) {
            ret.title = title!
        }
        
        if (target != nil && sel != nil) {
            ret.target = target!
            ret.action = sel!
        }
        
        return ret
    }
    
    static func confirm(msg:String, window:NSWindow, handler:(isAccepted:Bool) -> Void) {
        let a = NSAlert()
        a.messageText = msg
        a.addButtonWithTitle("Yes")
        a.addButtonWithTitle("No")
        
        a.beginSheetModalForWindow(window, completionHandler: { (modalResponse) -> Void in
            handler(isAccepted: modalResponse == NSAlertFirstButtonReturn)
        })
    }
    
    static func info(text:String) {
        print("Info:\(text)")
//        exit(-1)
    }
    
    static func error(text:String) {
        print("Quitting for error:\(text)")
        exit(-1)
    }
    
    static func warn(text:String) {
        print("Warning:\(text)")
//        exit(-1)
    }
    
    
}