//
//  PlayListUI.swift
//  slsPlayer
//
//  Created by aobskl on 5/30/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Cocoa
import AVFoundation

class PlayListUI : WindowedUI {
    
    let table:NSTableView = PLTableView(frame: NSRect(x: 0, y: 0, width: 500, height: 500))
    let toolbar:NSView = NSView()
    let pl:PlayList = PlayList()
    let scrollView = NSScrollView()
    let cmbPL = NSComboBox(frame: NSRect(x: 0, y: 0, width: 120, height: 20))
    
    var cmbPL2UrlMap = [String:String]()
    
    static let ntfPlayListUISelectionChanged = "ntfPlayListUISelectionChanged"
//    static let defaultFontSize:CGFloat = ceil((3.0*NSFont.smallSystemFontSize() + 1.0*NSFont.systemFontSize())/4.0)
    static let defaultFontSize:CGFloat = NSFont.smallSystemFontSize()
//    static let defaultFontWeight:CGFloat = NSFontWeightRegular
//    static let supportedFileExtensions = ["mp3", "m4a", "aac", "ac3", "aiff", "wav"]
    static let colid_title:String = "title"
    static let colid_url:String = "url"
    static let colid_duration:String = "duration"
    
    static let tag_btnsave = Utils.newTag()
    
    override init() {
        super.init()
    }
    
    func initTable() {
        let colTitle = NSTableColumn(identifier: PlayListUI.colid_title)
        colTitle.width = ceil(Utils.getSysCharsWidth(30, fontSize: PlayListUI.defaultFontSize)) + 2
        colTitle.minWidth = 100
        colTitle.headerCell.title = "Title"
        
        let colDur = NSTableColumn(identifier: PlayListUI.colid_duration)
        colDur.width = ceil(Utils.getSysTextSize("00:00:00", fontSize: PlayListUI.defaultFontSize).width) + 2
        colDur.minWidth = 30
        colDur.headerCell.title = "Dur"
        
        let colUrl = NSTableColumn(identifier: PlayListUI.colid_url)
        colUrl.width = ceil(Utils.getSysCharsWidth(45, fontSize: PlayListUI.defaultFontSize)) + 2
        colUrl.minWidth = 100
        colUrl.headerCell.title = "URL"
        
        table.allowsColumnResizing = true;
        table.allowsColumnSelection = false;
        table.allowsEmptySelection = false;
        table.allowsMultipleSelection = true;
//        table.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.SourceList
        table.usesAlternatingRowBackgroundColors = true;
        table.rowHeight = Utils.getSysTextSize(fontSize: PlayListUI.defaultFontSize).height + 2
        
        table.addTableColumn(colTitle)
        table.addTableColumn(colDur)
        table.addTableColumn(colUrl)
        
        table.registerForDraggedTypes([PLItem.keyType, NSFilenamesPboardType, NSURLPboardType])
        
        table.setDataSource(pl)
        table.setDelegate(self)
        
        table.bind(NSContentBinding, toObject: pl, withKeyPath: "arrangedObjects", options: nil)
        table.bind(NSSelectionIndexesBinding, toObject: pl, withKeyPath:"selectionIndexes", options: nil)
        table.bind(NSSortDescriptorsBinding, toObject: pl, withKeyPath: "sortDescriptors", options: nil)
        
        scrollView.documentView = table
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = true
        scrollView.borderType = NSBorderType.NoBorder
        
//        scrollView.horizontalScrollElasticity = NSScrollElasticity.None
//        scrollView.verticalScrollElasticity = NSScrollElasticity.None
    }
    
    func newToggleButton(title title:String? = nil, name:String? = nil) -> NSButton {
        let ret = NSButton()
        ret.setButtonType(.SwitchButton)
        
        if (title != nil) {
            ret.title = title!
        }
        
        if (name != nil) {
            ret.toolTip = "Toggle \(name!)"
        }
        return ret
    }
    
    func initToolbar() {
        
        toolbar.wantsLayer = true
        toolbar.layer!.backgroundColor =
//            NSColor.alternateSelectedControlColor().CGColor;
            CGColorCreateGenericRGB(0.31, 0.58, 0.8, 0.7);
        
        let btnrepeat = newToggleButton(title:"\u{221E}", name: "repeat")
        btnrepeat.bind(NSValueBinding, toObject: pl, withKeyPath: "isRepeat", options: nil)
        
        let btnrandom = newToggleButton(title:"R", name:"random")
        btnrandom.bind(NSValueBinding, toObject: pl, withKeyPath: "isRandom", options: nil)
        
        let btnsave = newMomentaryButton(tag: PlayListUI.tag_btnsave, title: "Save")
            
        cmbPL.toolTip = "Select Playlist"
        cmbPL.editable = false
        cmbPL.setDelegate(self)
        
        reloadCmbPL()
        
        let views = ["btnrepeat":btnrepeat, "btnrandom":btnrandom, "cmbPL":cmbPL, "btnsave":btnsave]
        for (_,view) in views {toolbar.addSubview(view);}
        
        Utils.makeLayout([
            "H:|-1-[btnrepeat(30)]-1-[btnrandom(30)]-1-[cmbPL]-5-[btnsave(35)]-1-|",
            "V:|-0-[btnrepeat(20)]-0-|",
            "V:|-0-[btnrandom(20)]-0-|",
            "V:|-0-[cmbPL(20)]-0-|",
            "V:|-0-[btnsave(20)]-0-|",
            ],views: views)
    }
    
    func getUserListsDir() -> NSURL? {
        return Utils.getUserFolder(NSSearchPathDirectory.ApplicationSupportDirectory, sub: "PlayLists/User")
    }
    
    func matchFileNameSansExt(str:String) -> String? {
        return str.firstSub(regex: Const.plExtRe!)
    }
    
    func reloadCmbPL() {
        cmbPL.removeAllItems()
        cmbPL2UrlMap.removeAll()
        
        guard let uld = getUserListsDir() else {
            return
        }
        
        let fm = NSFileManager.defaultManager()
        let urlrkeys = [NSURLIsDirectoryKey, NSURLIsRegularFileKey, NSURLIsReadableKey]
        
        do {
            for file in try fm.contentsOfDirectoryAtURL(uld, includingPropertiesForKeys: urlrkeys, options: NSDirectoryEnumerationOptions.SkipsPackageDescendants) {
                
                guard let lastp = file.pathComponents?.last, let fname = matchFileNameSansExt(lastp) else {
                    continue
                }
                
                guard cmbPL2UrlMap[fname] == nil else {
                    Utils.warn("Warning: More tha one file for: \(fname)")
                    continue
                }
                
                cmbPL2UrlMap[fname] = file.absoluteString
                cmbPL.addItemWithObjectValue(fname)
            }
        } catch let err {
            Utils.warn("Error: insertAsURLs: enumerating url: \(uld.absoluteString) -> \(err)")
        }
    }
    
    override func initComponents() {
        super.initComponents()
        
        initTable()
        initToolbar()
    }
    
    override func initWindow() {
//        let scrollView = table.enclosingScrollView!
        super.initWindow()
        
//        let cview = window.contentView!
//        cview.wantsLayer = true
//        cview.layer!.backgroundColor = NSColor.blueColor().CGColor

        
        let views = ["scrollView":scrollView, "toolbar": toolbar]
        for (_,view) in views {window.contentView!.addSubview(view);}
        
        Utils.makeLayout([
            "H:|-0-[scrollView]-0-|",
            "H:|-0-[toolbar]-0-|",
            "V:|-0-[scrollView]-0-[toolbar(20)]-0-|"
            ], views: views );
        
        window.title = "Playlist"
        
        //        window.opaque = false
        //        window.backgroundColor = NSColor.clearColor()
        //        window.movableByWindowBackground = false
        //        window.hasShadow = false
        //        window.ignoresMouseEvents = true
        
        
        let csize = NSMakeSize(ceil(Utils.getSysCharsWidth(75, fontSize: PlayListUI.defaultFontSize)) + 2,
                               table.rowHeight * 21)
        //        window.contentMinSize = csize
        window.setContentSize(csize)
        
        let mframe = NSScreen.mainScreen()!.frame
        window.setFrameTopLeftPoint(NSMakePoint(0.075 * mframe.width, 0.75 * mframe.height))
        
    }
    
    override func initEvents() {
        
        observe(Notifications.itemSelect.rawValue) { [weak self] notif in
            guard let plui = self else {
                return
            }
            
            guard let selectDir = notif.userInfo?[Notifications.itemSelect.rawValue] as? String else {
                return
            }
            var isPrev = false
            
            if selectDir == Notifications.itemSelectNext.rawValue {
                isPrev = false //rdnt
            } else if selectDir == Notifications.itemSelectPrev.rawValue {
                isPrev = true
            } else {
                return
            }
            
            plui.selectNextOrPrev(isPrev, isForceErase:true)
//            plui.pl.append(PLItem(url: (NSURL.fileURLWithPath("/Users/aobskl/temp/music1.mp3")).absoluteString, title: "temp_music..."))
        }
        
        observe(Notifications.itemStopped.rawValue) { [weak self] notif in
            guard let plui = self else {
                return
            }
            plui.selectNextOrPrev(false)
        }
        
        table.target = self
        table.doubleAction = #selector(self.tableDblClicked(_:))
        
        super.initEvents()
    }
    
    override func uninitEvents() {
        
        super.uninitEvents()
    }
    
    func selectNextOrPrev(isPrev:Bool=false, isForceErase:Bool=false) -> Int? {
        guard table.numberOfRows > 0 else {
            return PlayList.idxNil
        }

        var target = pl.nextOrPrevInQueue(isPrev:isPrev);
        if target == nil && isForceErase {
            pl.eraseCounters()
            target = pl.nextOrPrevInQueue(isPrev:isPrev);
        }
        
        if (target != nil) {
            pl.setSelectionIndex(target!)
//            selectItemAt(target!)
            tableDblClicked(table)
        }
        
        return target
    }
    
    func reloadRow(index:Int) {
        table.reloadDataForRowIndexes(NSIndexSet(index: index),
                                      columnIndexes: NSIndexSet(indexesInRange: NSRange(location: 0, length: table.numberOfColumns))
        )
    }
    
    func tableDblClicked(sender:AnyObject) {
        //@NOTICE: call always-only this method for .itemSelected
        assert(sender as! NSObject === table, "tableDblClicked-> sender != table")
        guard table.selectedRow >= 0 else {
            return
        }
        let item = pl[table.selectedRow]
        let old = pl.getLastSelectedIndex()
        
        pl.select(table.selectedRow)
        
        table.scrollRowToVisible(table.selectedRow)

        // refreshes text colors..
        if (old != nil) {
            reloadRow(old!)
        }
        reloadRow(table.selectedRow)
        
        sendEvent(Notifications.itemSelected.rawValue, info: [PLItem.keyType: item])
    }
    
    func action_cmbPL(sender:AnyObject) {
        guard let item = cmbPL.objectValueOfSelectedItem as? String else {
            return
        }
        guard let urlstr = cmbPL2UrlMap[item] else {
            return
        }
        
        guard let url = NSURL(string: urlstr) else {
            return
        }
//            NSURL(fileURLWithPath: item, isDirectory: false, relativeToURL: dir)
        pl.replace(0..<pl.count)
        pl.insertURLs([url], pos: 0)
    }
    
    override
    func action_btn(sender:AnyObject) {
        let btn = sender as! NSButton
        
        switch btn.tag {
        case PlayListUI.tag_btnsave:
            
            let a = NSAlert()
            a.messageText = "Please enter a value"
            a.addButtonWithTitle("Save")
            a.addButtonWithTitle("Cancel")
            
            let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            inputTextField.stringValue = cmbPL.stringValue
            inputTextField.selectText(nil)
            
            a.accessoryView = inputTextField
            
            a.beginSheetModalForWindow(self.window, completionHandler: { (modalResponse) -> Void in
                if modalResponse == NSAlertFirstButtonReturn {
                    let enteredString = inputTextField.stringValue
                    print("Entered string = \"\(enteredString)\"")
                    let str = enteredString
                    
//                    let fman = NSFileManager.defaultManager()
                    guard let udir = self.getUserListsDir() else {
                        return
                    }
                    let url = udir.URLByAppendingPathComponent(str, isDirectory: false).URLByAppendingPathExtension(Const.plExt)
                    
//                    if fman.fileExistsAtPath(url.path!)
                    
                    guard self.pl.write(url) == nil else {
                        return
                    }
                    if self.cmbPL2UrlMap[str] == nil {
                        self.reloadCmbPL()
                        self.cmbPL.selectItemWithObjectValue(str)
                    } else {
                        self.cmbPL2UrlMap[str] = url.absoluteString
                        if self.cmbPL.indexOfSelectedItem != self.cmbPL.indexOfItemWithObjectValue(str) {
                            self.cmbPL.selectItemWithObjectValue(str)
                        }
                    }
                }
            })
        default:
            Utils.error("unknown tag: \(btn.tag)")
        }
        
    }
    
}
////////////////////////////////////////////////////////////////////////////

class FilenameFormatter : NSFormatter {
    //@TODO..
}

////////////////////////////////////////////////////////////////////////////

extension PlayListUI : NSComboBoxDelegate {
    func comboBoxSelectionDidChange(notification: NSNotification) {
        if notification.object === cmbPL {
            action_cmbPL(cmbPL)
        }
    }
}

////////////////////////////////////////////////////////////////////////////
    
enum CellBindingType: UInt {
    case None
    case Text
    case NumberToTimeInterval
}

extension PlayListUI : NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view:PLTextCellView?
        assert(tableColumn != nil, "nil tableColumn!!")
        view = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as? PLTextCellView
        var bindingType:CellBindingType = .None
        
        switch tableColumn!.identifier {
            case PlayListUI.colid_title:
                bindingType = .Text
            case PlayListUI.colid_url:
                bindingType = .Text
            case PlayListUI.colid_duration:
                bindingType = .NumberToTimeInterval
            default:
                assert(false, "No case is impelemented for \(tableColumn!.identifier)")
        }
        
//        let text = pl[row].title
        if view == nil {
//            print("new cellview for: \(text)")
            view = PLTextCellView(playList:pl, columnName: tableColumn!.identifier, bindingType: bindingType)
        } else {
//            print("reused cell: \(text) for old: \(view!.textValue)")
        }
        
        return view
    }
    
    func tableView(tableView: NSTableView, shouldEditTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
        //@TODO: implement editing sometime...
        return false
    }
}

////////////////////////////////////////////////////////////////////////////

class PLTableView : NSTableView {
    
    override
    init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override
    func keyDown(theEvent:NSEvent) {
//        Swift.print("event: chars:\(theEvent.characters), chars-mod:\(theEvent.charactersIgnoringModifiers), keyCode:\(theEvent.keyCode)")
        var consumed = false
        if (theEvent.charactersIgnoringModifiers == "\u{7F}" && !theEvent.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask)) {

            guard let pl = dataSource() as? PlayList else {
                Swift.print("Error: non playlist datasource for delete op.")
                return
            }
            consumed = pl.ccp_delete()
        }
        if !consumed {
            super.keyDown(theEvent)
        }
        
//        interpretKeyEvents([theEvent])
    }
    
    
//    override func deleteBackward(sender: AnyObject?) {
//    }
}

////////////////////////////////////////////////////////////////////////////

class PLTextCellView: NSTableCellView {
   
    init(playList:PlayList, columnName:String, bindingType:CellBindingType) {
        super.init(frame: NSMakeRect(0, 0, 0, 0))
        identifier = columnName
        
        // Create a text field for the cell
        let textField = NSTextField()
        textField.backgroundColor = NSColor.clearColor()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.bordered = false
        textField.controlSize = NSControlSize.SmallControlSize
        textField.lineBreakMode = .ByTruncatingMiddle
        
        addSubview(textField)
        self.textField = textField
        
        // Constrain the text field within the cell
        addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("H:|[textField]|",
                options: [],
                metrics: nil,
                views: ["textField" : textField]))
        
        addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("V:|[textField]|",
                options: [],
                metrics: nil,
                views: ["textField" : textField]))
        
        self.pl = playList
        self.bindingType = bindingType
        link()
    
    }
    
    weak
    var pl:PlayList? = nil
    
    var bindingType:CellBindingType = .None
    
    func fixVisualAttributes() {
        guard let item = (objectValue as? PLItem) else {
            return
        }
        if ((item === pl!.lastItem?.value) ?? false) {
            textField?.font = NSFont.boldSystemFontOfSize(PlayListUI.defaultFontSize)
        } else {
            textField?.font = NSFont.systemFontOfSize(PlayListUI.defaultFontSize)
        }
    }
    
    var textValue:AnyObject? {
        get {
            return textField?.stringValue
        }
        set(val) {
            if (val != nil) {
                textField?.stringValue = String(val!)
            } else {
                textField?.stringValue = ""
            }
            textField?.toolTip = textField?.stringValue
        }
    }
    
    override
    var objectValue: AnyObject? {
        didSet {
            fixVisualAttributes()
        }
    }
    
    override
    func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard let obj = objectValue as? NSObject else {
            return
        }
        let val = obj.valueForKey(identifier!)
        
        switch bindingType {
            case .Text:
                textValue = val
            case .NumberToTimeInterval:
                let num = val as? NSNumber
                if (num?.doubleValue > 0.0) {
                    textValue = Utils.getTimeString(Int(num!))
                } else {
                    textValue = Const.textPlaceholder
                }
            default:
                break
        }
    }
    
    
    private
    func link() {
        switch bindingType {
            case .Text:
                bind("textValue",
                     toObject: self,
                     withKeyPath: "objectValue."+identifier!,
                     options: [NSNullPlaceholderBindingOption:Const.textPlaceholder])
            case .NumberToTimeInterval:
                addObserver(self, forKeyPath: "objectValue."+identifier!, options: [], context: nil)
            default:
                break
        }
    }
    
    private
    func unLink() {
        switch bindingType {
            case .Text:
                unbind("textValue")
            case .NumberToTimeInterval:
                removeObserver(self, forKeyPath: "objectValue."+identifier!)
            default:
                break
        }
    }
    
    deinit {
        unLink()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} /// class PLTextCellView


/////////////////////////////////////////////

class PLTextView: NSTextField {
    
    init(columnName:String) {
        super.init(frame: NSMakeRect(0, 0, 0, 0))
        
        drawsBackground = false
        bezeled = false
        editable = false
        selectable = false
        
        displayText = ""
        isSelected = false
        controlSize = NSControlSize.SmallControlSize
        self.columnName = columnName
        self.identifier = columnName
        
//        bind("displayText", toObject: self, withKeyPath: "objectValue.\(columnName)",
//             options: [NSNullPlaceholderBindingOption:"--"])
//        bind(NSValueBinding,
//                       toObject: self,
//                       withKeyPath: "objectValue."+columnName,
//                       options: nil)
    }
    
    var columnName:String!
    
    var displayText:AnyObject {
        get {
            return stringValue
        }
        set(val) {
//            self.objectValue = val
            stringValue = String(val)
//            Swift.print("updating stringvalue to: \(stringValue)")
            toolTip = stringValue
            lineBreakMode = .ByTruncatingMiddle
        }
    }
    
    weak
    var item:PLItem? = nil
    
    
    override
    var objectValue: AnyObject? {
        
        didSet {
            unbind("displayText")
            Swift.print("did set:\(objectValue) ")
            item = objectValue as? PLItem
            if (item != nil) {
                bind("displayText", toObject: self, withKeyPath: "objectValue.\(columnName)",
                     options: [NSNullPlaceholderBindingOption:"--"])
            }
        }
    }
 
    
    deinit {
        unbind("displayText")
    }
    
    override
    func prepareForReuse() {
        unbind("displayText")
        super.prepareForReuse()
    }
    
    private
    var _isSelected:Bool = false
    
    var isSelected:Bool {
        get {
            return _isSelected
        }
        set(val) {
            _isSelected = val
            if (_isSelected) {
                self.textColor = NSColor.orangeColor()                
            } else {
                self.textColor = NSColor.blackColor()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

