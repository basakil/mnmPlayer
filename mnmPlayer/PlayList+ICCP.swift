//
//  PlayList+ICCP.swift
//  mnmPlayer
//
//  Created by basakil on 8/4/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Cocoa


/////////////////////////////////////////////////////////////////////////

extension PlayList : ICCP {
    
    func ccp_cut(pboard:NSPasteboard) -> Bool {
        if (ccp_copy(pboard)) {
            return ccp_delete()
        }
        return false
    }
    
    func ccp_copy(pboard:NSPasteboard) -> Bool {
        if selectionIndexes.count > 0 {
            pboard.clearContents()
            
            var urls = [NSURL]()
            var strs = [String]()
            for idx in selectionIndexes {
                let url = NSURL(string: self[idx].url)
                if url != nil {
                    urls.append(url!)
                    strs.append(self[idx].url)
                }
            }
            
            pboard.declareTypes([NSURLPboardType, NSStringPboardType], owner: self)
//            let zurls = NSKeyedArchiver.archivedDataWithRootObject(urls)
//            pboard.setData(zurls, forType: NSURLPboardType)
            
            pboard.writeObjects(strs)
            pboard.writeObjects(urls)
            
            return true
        }
        return false
    }
    
    func ccp_paste(pboard:NSPasteboard, toPos:Int? = nil) -> Bool {
        let dropRow:Int = (toPos ?? min(max(selectionIndex, 0), count))
        var isChanged:Bool = false
        
        guard let pbtypes = pboard.types else {
            Utils.warn("ccp: No pboard type for paste ??!")
            return false
        }
        
        if pbtypes.contains(NSFilenamesPboardType) {
            
            guard let files = pboard.propertyListForType(NSFilenamesPboardType) as? [String] else {
                Utils.warn("DnD: No [String] for file drops ??!")
                return false
            }
            
            var urls = [NSURL]()
            urls.reserveCapacity(Int(Double(files.count)*1.2) + 2)
            
            for str in files {
                urls.append(NSURL.fileURLWithPath(str))
            }
            
            let ret = insertURLs(urls, pos: dropRow)
            isChanged = ret > 0
            Utils.info("Dnd: Inserted \(ret) items.")
            
        } else if pbtypes.contains(NSURLPboardType) {
            //@TODO? from another instance of the application...
            guard let urls = pboard.readObjectsForClasses([NSURL.self], options: nil) as? [NSURL] else {
                Utils.warn("DnD: No [NSURL] for url drops ??!")
                return false
            }
            
            let ret = insertURLs(urls, pos: dropRow)
            isChanged = ret > 0
            Utils.info("Dnd: Inserted \(ret) items.")
        }
        
        return isChanged;
    }
    
    func ccp_delete() -> Bool {
        let selected = selectionIndexes
        removeObjectsAtArrangedObjectIndexes(selected)
        return selected.count > 0
    }
    
    func ccp_selectAll() -> Bool {
        if (count > 0) {
            let idxSet = NSIndexSet(indexesInRange: NSRange(location:startIndex, length: count))
            return setSelectionIndexes(idxSet)
        }
        return false
    }
    
}

//////////////
