//
//  String+Extension.swift
//  SortLetter
//
//  Created by MountainX on 2019/2/21.
//  Copyright © 2019 MTX Software Technology Co.,Ltd. All rights reserved.
//

import Foundation

extension String {
    
    /// 在字符串中查找另一字符串首次出现的位置（或最后一次出现位置）
    ///
    /// - Parameters:
    ///   - sub: 查找的字符串
    ///   - backwards: 是否从末尾开始查找（默认为false）
    /// - Returns: 首次出现的位置（没有找到则返回-1）
    ///（如果backwards参数设置为true，则返回最后出现的位置）
    func positionOf(sub: String, backwards: Bool = false)->Int {
        // 如果没有找到就返回-1
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    var length: Int {
//        return self.characters.count
        return self.count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)), upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
//    func dropLast(_ n: Int = 1) -> String {
//        return String(characters.dropLast(n))
//    }
//
//    var dropLast: String {
//        return dropLast()
//    }
}
