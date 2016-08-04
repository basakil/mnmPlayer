//
//  main.swift
//  slsPlayer
//
//  Created by basakil on 5/16/16.
//  Copyright © 2016 AoB. All rights reserved.
//

import Cocoa

//class Main {
//    init() {
//
//    }
//}

let app:NSApplication = NSApplication.sharedApplication()
app.setActivationPolicy(.Regular)

let delegate = AppDelegate()
app.delegate = delegate

app.run()

/*
let urlrkeys = [NSURLIsRegularFileKey, NSURLIsReadableKey]

guard let urlenum = NSFileManager.defaultManager().enumeratorAtURL(
    NSURL.fileURLWithPath("/Users/aobskl/Media/Music/2000s/parent_link/subDir"),
    includingPropertiesForKeys: urlrkeys,
    options: NSDirectoryEnumerationOptions.SkipsPackageDescendants,
    errorHandler: { (url:NSURL, error:NSError) -> Bool in
        print("Error enumerating url: \(url.absoluteString) -> \(error.localizedDescription)")
        return true
    }
    ) else {print("enumeratorAtURL returned null..."); exit(-1);}

for item in urlenum {
    guard let url = item as? NSURL else {
        print("No url in enumeraion??");
        continue
    }
    guard let rvs = try url.resourceValuesForKeys(urlrkeys) as? [String:AnyObject] else {
        print("No resource values...");
        continue
    }
    
    print("url name: \(url.absoluteString)::")
    for (key, val) in  rvs {
        print("\tkey: \(key), val=\(val)", separator: " - ", terminator: ";")
    }
    print("..done..")
}
*/
