//
//  TXTReadHelper.swift
//  SortLetter
//
//  Created by MountainX on 2019/2/21.
//  Copyright © 2019 MTX Software Technology Co.,Ltd. All rights reserved.
//

import UIKit

class TXTReadHelper: NSObject {
    class func fetchStringFromFile(filePath: String) -> NSString? {
        var content: NSString? = nil
        do {
            // couldn’t be opened using text encoding Unicode (UTF-8).
            // let enc = String.Encoding.utf8.rawValue
            let cfEnc = CFStringEncodings.GB_18030_2000
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            content = try NSString(contentsOfFile: filePath, encoding: enc)
        } catch let error as NSError {
            print(error)
        }
        return content
    }
}
