//
//  PLItem.swift
//  slsPlayer
//
//  Created by aobskl on 5/30/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Cocoa

final class PlayList : NSArrayController, MutableCollectionType, SequenceType {
    //@CONS: implementing MutableSliceable and RangeReplaceableCollectionType
//    var pl:[PLItem]!
    
    var lastCounter:Int = 0
    var lastIdx:Int = -1
    var lastItem:Weak<PLItem>? = nil
    
    static let idxNil:Int = -1
    
    dynamic
    var isRepeat:Bool = false
    
    dynamic
    var isRandom:Bool = true
    
//    var controller = NSArrayController()
    
    required init () {
//        pl = []
//        pl.reserveCapacity(150)
        super.init(content:nil)
//        print("String(PLItem.self)=\(String(PLItem.self))")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MutableCollectionType methods:
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return (arrangedObjects as! NSArray).count
//        return pl.count
    }
    
    subscript(index:Int) -> PLItem {
        get {
            return (arrangedObjects as! NSArray)[index] as! PLItem
//            return arrangedObjects[index]
//            return pl[index]
        }
        set(newElm) {
            print("indexed set is not allowed in PLItem..")
            removeObjectAtArrangedObjectIndex(index)
            insertObject(newElm, atArrangedObjectIndex: index)
        }
    }
    
    //SequenceType:
    func generate() -> AnyGenerator<PLItem> {
        var index = 0
        return AnyGenerator<PLItem> {
            if index < self.count {
                defer {index += 1}
                return self[index]
            }
            return nil
        }
    }
    
    //ExtensibleCollectionType:
    func append(item:PLItem) {
//        pl.append(item)
        addObject(item)
//        pl[pl.count-1].index = pl.count-1
    }
    
    func removeAtIndex(index:Int) -> PLItem {
//        defer {updateItemIndexes(index..<pl.count)}
        print("removing index: \(index)")
        let ret = self[index]
        removeObjectAtArrangedObjectIndex(index)
//        removeSelectionIndexes(NSIndexSet(index: index))
//        return pl.removeAtIndex(index)
        return ret
    }
    
    func insert(item:PLItem, atIndex:Int) {
//        pl.insert(item, atIndex: atIndex)
        insertObject(item, atArrangedObjectIndex: atIndex)
//        updateItemIndexes(atIndex..<pl.count)
    }
    
    func replace(range: Range<Int>, with:[PLItem]=[PLItem]()) {
        let nsrange = NSRange(location:range.startIndex, length:range.endIndex-range.startIndex)
        print("removing range: \(range)")
        removeObjectsAtArrangedObjectIndexes(NSIndexSet(indexesInRange: nsrange))
//        insertObjects(with, atArrangedObjectIndexes: NSIndexSet(index: range.startIndex))
        if with.count > 0 {
            print("not implemented in controller")
        }
//        pl.replaceRange(range, with: with)
    }
   
    func select(idx:Int) {
        let item:PLItem = self[idx]
        lastIdx = idx
        lastItem = Weak<PLItem>(value: item)
        lastCounter += 1
        item.counter = lastCounter
       
        //refresh for bindings..
        item.url = item.url + "."
        item.url = item.url.substringToIndex(item.url.endIndex.advancedBy(-1))
        if item.title != nil {
            item.title = item.title! + "."
            item.title = item.title!.substringToIndex(item.title!.endIndex.advancedBy(-1))
        }
    }
        
    func getLastSelectedIndex() -> Int? {
        //valid index?
        if lastIdx >= 0 && count >= 0 {
            //valid item?
            if lastItem?.value != nil {
                //still in the same place?
                if lastIdx < count && lastItem!.value === self[lastIdx] {
                    return lastIdx
                } else {
                    //moved.. O(n)
                    return itemToIndex(lastItem!.value!)
                }
            }
            //last item erased.. find nearest.. O(n)
            return getMaxCounterIndex()
        }
        return nil
    }
    
    func itemToIndex(item:PLItem) -> Int? {
        let cnt = count
        for f1 in 0..<cnt {
            if self[f1] === item {
                return f1
            }
        }
        return nil
    }
    
    func getMaxCounterIndex() -> Int? {
        let cnt = count
        var max = -1
        var idx:Int? = nil
        for f1 in 0..<cnt {
            if self[f1].counter > max {
                max = self[f1].counter
                idx = f1
            }
        }
        return idx
    }
    
    func eraseCounters() {
        let cnt = count
        for f1 in 0..<cnt {
            self[f1].counter = 0
        }
        lastCounter = 0
    }
    
    func nextOrPrevInQueue(isPrev isPrev:Bool) -> Int? {
        guard count > 0 else {
            return nil
        }
        
        //find index of last played..
        var idx = getLastSelectedIndex()
        
        idx = getNextIndex(idx, isReverse:isPrev)
        if idx == nil {
            if isRepeat {
                idx = getLastSelectedIndex()
                eraseCounters()
                if idx != nil && count > 1 {
                    select(idx!)
                }

                idx = getNextIndex(idx, isReverse:isPrev)
            }
        }
        
        return idx
    }
    
    private
    func getNextIndex(ind:Int?, isReverse:Bool=false) -> Int? {
        var idx:Int = ind ?? -1
        let cnt = count
        
        guard cnt > 2 else {
            idx += (isReverse ? -1 : +1)
            idx = (idx+cnt)%cnt
            return (self[idx].counter==0 ? idx : nil)
        }
        
        var start = 1
        
        if isRandom {
            start = random()%(cnt-1)
        }
        let end = cnt - 1 + start
        
        for f1 in start..<end {
            idx += (isReverse ? -f1 : +f1)
            idx = (idx+cnt)%cnt
            if self[idx].counter == 0 {
                return idx
            }
        }

        return nil
    }
    
}

/////////////////////////////////////////////////////////////////////////

extension PlayList : ICCP {
    
    func ccp_cut() -> Bool {
        return false
    }
    
    func ccp_copy() -> Bool {
        return false
    }
    
    func ccp_paste() -> Bool {
        return false
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

/////////////////////////////////////////////////////////////////////////
