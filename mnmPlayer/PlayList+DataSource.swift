//
//  PLArrayController.swift
//  slsPlayer
//
//  Created by basakil on 7/4/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Cocoa

extension PlayList: NSTableViewDataSource, NSDraggingSource {
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        let zNSIndexSetData = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
        pboard.declareTypes([PlayList.kSelectionIndexes], owner: self)
        pboard.setData(zNSIndexSetData, forType: PlayList.kSelectionIndexes)
        return true
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        if dropOperation != .Above {
            tableView.setDropRow(row, dropOperation: .Above)
        }
        //delete icon for outside drops... does not work...:
        //        let mask = info.draggingSourceOperationMask()
        //        print("mask = \(mask.rawValue)")
        //        if mask.contains(NSDragOperation.None) ||
        //            mask.contains(NSDragOperation.Delete){
        //            print("mask contains.. ")
        //            return NSDragOperation.Generic
        //        }
        
        if info.draggingSource() as? NSTableView === tableView {
            return NSDragOperation.Move
        }
        return NSDragOperation.Copy
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        let pboard = info.draggingPasteboard()
        var dropRow = row
        var isChanged:Bool = false
        
        guard let pbtypes = pboard.types else {
            Utils.warn("DnD: No pboard type for drop ??!")
            return false
        }
        
        if info.draggingSource() as? NSTableView === tableView {
            guard let rowData = pboard.dataForType(PlayList.kSelectionIndexes) else {
                Utils.warn("DnD: No data for self drop ??!")
                return false
            }
            
            //@TODO modify and make swiftly sane....
            NSKeyedUnarchiver.unarchiveObjectWithData(rowData)?.enumerateIndexesUsingBlock(
                {[weak self]  (dragRow:Int, _:UnsafeMutablePointer<ObjCBool>) in
                    guard self != nil else {
                        return
                    }
                    if dragRow < dropRow {
                        self!.insert(self![dragRow], atIndex: dropRow)
                        self!.removeAtIndex(dragRow)
                    } else {
                        let zData = self!.removeAtIndex(dragRow)
                        self!.insert(zData, atIndex: dropRow)
                        dropRow += 1
                    }
                    
            })
            
            
            isChanged = true;
            
        } else if pbtypes.contains(PlayList.kSelectionIndexes) {
            Utils.warn("DnD: PLItem should DnD should be carried in the same table!..")
        } else {
            isChanged = ccp_paste(pboard, toPos: dropRow)
        }
        
        return isChanged;
        
    } // func
    
    
    func tableView(tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint, forRowIndexes rowIndexes: NSIndexSet) {
        
        session.animatesToStartingPositionsOnCancelOrFail = false
    }
    
    func tableView(tableView: NSTableView, draggingSession session: NSDraggingSession, endedAtPoint screenPoint: NSPoint, operation: NSDragOperation) {
        
        //drop outside..
        if operation == NSDragOperation.None {
            ccp_delete()
        }
        
    }
    
    //NSDraggingSource: Supposed to change caret to trash while dropping outside.. Does not work...
    func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        
        switch context {
        case .OutsideApplication: return .None
        case .WithinApplication: return .Move
        }
        
    }
    
    // no need for tables using cocoa bindings..
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return count;
    }
    
    func tableView(tableView: NSTableView,
                   objectValueForTableColumn tableColumn: NSTableColumn?,
                                             row: Int) -> AnyObject? {
        
        // cell-binding expects the item (obj) assigned to its objectValue
        let ret:AnyObject? = self[row]
        return ret
    }
    
}

/////////////////////////////////////////////////////////////////////////