//
//  PlayList-IO.swift
//  slsPlayer
//
//  Created by aobskl on 7/6/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Foundation
import AVFoundation

extension PlayList {
    
    func parseUrlStr(str:String, relative:NSURL?) -> NSURL? {
        let ustr = str
        var item:NSURL? = nil
        
        if ustr.indexOf("://") == nil {
            if ustr[ustr.startIndex] != "/" {
                item = NSURL.fileURLWithPath(ustr, relativeToURL: relative)
            } else {
                item = NSURL.fileURLWithPath(ustr)
            }
        } else {
            item = NSURL(string: ustr)
        }
        return item
    }
    
    func read(url:NSURL, encoding : UInt = NSUTF8StringEncoding, handler: ([NSURL]? -> Void)?  = nil) -> [NSURL] {
        var ret = [NSURL]()
//        var strStream:Any
        
        guard url.fileURL else {
            print("Warning: insertAsURLs: Non-file url:\(url.absoluteString)");
            return ret
        }
        
        guard let stream = StreamReader(url: url, encoding:encoding) else {
            print("Warning: insertAsURLs: Not StreamReader readable:\(url.absoluteString)");
            return ret
        }
        stream.rewind()
        
        for line in stream {
            let str = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            //@TODO: handle attributes..
            if str.hasPrefix("#EXT") {
                continue
            }
            
            if str.characters.count < 1 {
                continue
            }
            
            let item:NSURL? = parseUrlStr(str, relative: url)
            if item != nil {
                ret.append(item!)
            }
        }
        
        return ret
    }
    
    func write(url:NSURL) -> ErrorType? {
        
        let fman = NSFileManager.defaultManager()
        
        do {
//            try "".writeToFile(url.path!, atomically: true, encoding: NSUTF8StringEncoding)
            fman.createFileAtPath(url.path!, contents: nil, attributes: nil)
            
            let handle = try NSFileHandle(forWritingToURL: url)
            defer {handle.closeFile()}
            
            handle.truncateFileAtOffset(0)
            
            for item in self {
                let outStr = "\(item.url)\n"
                guard let data = outStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
                    continue
                }
                handle.writeData(data)
            }
            
        } catch let err {
            Utils.warn("Could not write to url: \(url.absoluteString) -> \(err)")
            return err
        }
        return nil
    }
        
    func insertURLs(urls:[NSURL], pos:Int) -> Int {
        
        let urlrkeys = [NSURLIsDirectoryKey, NSURLIsRegularFileKey, NSURLIsReadableKey]
        var nurls:Array<NSURL> = []
        //        nurls.reserveCapacity(Int(Double(items.count)*1.2) + 2)
        
        var urls2 = [NSURL]()
        urls2.reserveCapacity(Int(1.1 * Double(urls.count)))
        
        for url in urls {
            if let _ = url.path?.firstSub(regex: Const.plExtRe!) {
                if url.fileURL {
                    urls2.appendContentsOf(read(url))
                } else {
                    NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: { [weak self] (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
                        
                        if self != nil && location != nil {
//                            var sbsString = location!.absoluteString
                            let isFile = location!.fileURL
                            if isFile {
                                self!.insertURLs(self!.read(location!), pos: pos)
                            }
                        }
                    }).resume()
                }
                continue
            }
            urls2.append(url)
        }
        
        // fill up nurls with
        for url in urls2 {
            
            //check the url..
            if (url.fileURL) {
                do {
                    let rvs = try url.resourceValuesForKeys(urlrkeys)
                    let isReadable = rvs[NSURLIsReadableKey]
                    if !(isReadable as? Int == 1 || isReadable as? Bool == true) {
                        print("Warning: insertAsURLs: Not readable:\(url.absoluteString)");
                        continue
                    }
                    let isFile = rvs[NSURLIsRegularFileKey]
                    if isFile as? Int == 1 || isFile as? Bool == true {
                        nurls.append(url)
                        continue
                    }
                    let isDirectory = rvs[NSURLIsDirectoryKey]
                    if !(isDirectory as? Int == 1 || isDirectory as? Bool == true) {
                        print("Warning: insertAsURLs: Not file or directory:\(url.absoluteString)");
                        continue
                    }
                } catch let errr {
                    print("Warning: insertAsURLs: No resource values for:\(url.absoluteString), errr:\(errr)");
                    continue
                }
                
                //Directory.. append it:
                //@TODO: make first-level symbolic links work..
                guard let urlenum = NSFileManager.defaultManager().enumeratorAtURL(
                    url,
                    includingPropertiesForKeys: urlrkeys,
                    options: NSDirectoryEnumerationOptions.SkipsPackageDescendants,
                    errorHandler: { (url:NSURL, error:NSError) -> Bool in
                        print("Error: insertAsURLs: enumerating url: \(url.absoluteString) -> \(error.localizedDescription)")
                        return true
                    }
                    ) else {print("Info: insertAsURLs: empty url:\(url.absoluteString)"); continue;}
                
                for item in urlenum {
                    guard let url = item as? NSURL else {
                        print("No url in enumeraion??");
                        continue
                    }
                    do {
                        let rvs = try url.resourceValuesForKeys(urlrkeys)
                        
                        let isFile = rvs[NSURLIsRegularFileKey]
                        if isFile as? Int == 1 || isFile as? Bool == true {
                            let isReadable = rvs[NSURLIsReadableKey]
                            if !(isReadable as? Int == 1 || isReadable as? Bool == true) {
                                print("Warning: insertAsURLs: Not nreadable:\(url.absoluteString)");
                                continue
                            }
                            nurls.append(url)
                            continue
                        }
                    } catch let errr {
                        print("Warning: insertAsURLs: No nresource values for:\(url.absoluteString), errr:\(errr)");
                        continue
                    }
                }
            } else { // not fileUrl:
                //@TODO filter non-file url's
                nurls.append(url)
            }
            
            
        } // for url in urls
        var insPos = pos
        
        //we have all urls now in nurls:
        
        let avTypes = AVURLAsset.audiovisualTypes()
        var extToUriDict:[String:String] = [:]
        var isInsert:Bool = true
        for url in nurls {
            if url.fileURL {
                guard let pathExtension = url.pathExtension else {
                    print("Warning: insertAsURLs: could not get pathextension for url: \(url.absoluteString) !")
                    //                    return false
                    continue
                }
                
                var preferredUTI = extToUriDict[pathExtension]
                if preferredUTI == nil {
                    guard let rv = UTTypeCreatePreferredIdentifierForTag(
                        kUTTagClassFilenameExtension,
                        pathExtension,
                        nil)?.takeRetainedValue() else {
                            
                            print("Warning: insertAsURLs: could not UTTypeCreatePreferredIdentifierForTag for extension: \(pathExtension) !")
                            continue
                    }
                    preferredUTI = String(rv)
                    extToUriDict[pathExtension] = preferredUTI
                }
                
                isInsert = avTypes.contains(preferredUTI!)
            } else {
                // check url stuff???
                isInsert = true
            }

            
            //            print("Info: insertAsURLs: UTI=\(preferredUTI) for ext:\(pathExtension)")
            if  isInsert {
                let plitem = PLItem(url:url.absoluteString, title: url.lastPathComponent)
                insert(plitem, atIndex: insPos)
                insPos += 1
            }
            
        }
        
        return insPos - pos
    } // func insertURLs
    
}