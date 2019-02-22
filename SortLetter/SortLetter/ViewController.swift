//
//  ViewController.swift
//  SortLetter
//
//  Created by MountainX on 2019/2/21.
//  Copyright © 2019 MTX Software Technology Co.,Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //test
//        test()
        
        let keyword = "YncHroN"
        let response: (word: String, mean: String?, exact: Bool) = SQLiteHelper.shareHelper.searchFromOxfordDict(keyword: keyword)
        if (response.mean != nil) && response.exact {
            print("Find it!\n\(response.word) : \(response.mean!)")
        } else if (response.mean != nil) && !response.exact {
            print("Sorry: Can't find the meaning of \(keyword).\nAre you looking for\n\(response.word) : \(response.mean!)")
        } else {
            print("Sorry: Can't find the meaning of \(keyword).")
        }
    }
    
    func test() {
        let filePath = Bundle.main.path(forResource: "Oxford-Chinese-Dictonary", ofType: "txt")
        let fileContent: NSString? = TXTReadHelper.fetchStringFromFile(filePath: filePath!)
        // print(fileContent ?? "Error: fileContent is Nil")
        let mutableFileContent: NSMutableString = fileContent?.mutableCopy() as! NSMutableString
        //        let lines = mutableFileContent.replaceOccurrences(of: "\n", with: "", options: .literal, range: NSRange(location: 0, length: (fileContent?.length)!))
        // lines:103977
        //        print("lines:\(lines+1)")
        // dict : [String,String]
        let components: [String] = mutableFileContent.components(separatedBy: "\n")
        //        print("lines:\(components.count)")
        //        let mutableDict = NSMutableDictionary(capacity: components.count)
        let dataArr = NSMutableArray(capacity: components.count)
        for line: String in components {
            if line.count == 0 {continue}
            let sub = "\t"
            let pos = line.positionOf(sub: sub, backwards: false)
            let key = line.substring(toIndex: pos)
            var value = line.substring(fromIndex: pos + sub.count)
            // 移除首尾的空格和换行
            value = value.trimmingCharacters(in: .whitespacesAndNewlines)
            let dict: [String : String] = [key : value]
            dataArr.add(dict)
        }
        //        print(mutableDict)
        var keyword = "synchronized"
        let originalKeyword = keyword
        var meaning: String?
        var searchCount: Int = 0
        // 模拟模糊搜索
        
        while keyword.count > 0 {
            keyword = originalKeyword
            searchCount = 0
            for i in 0..<dataArr.count {
                let dict: [String : String] = dataArr.object(at: i) as! [String : String]
                meaning = dict[keyword]
                searchCount += 1
                if meaning != nil { break }
            }
            if meaning != nil { break }
            keyword = keyword.substring(toIndex: originalKeyword.count - searchCount)
        }
        
        
        // debugPrint和print输出有差异,比如：debugPrint换行符不能正常换行，会使用双引号包裹输出结果
        // "v.同步\r"
        //        debugPrint(meaning ?? "")
        // v.同步
        //        print(meaning ?? "")
        if meaning != nil && searchCount == 1 {
            print("\(originalKeyword) : \(meaning ?? "")")
        } else if meaning != nil && searchCount > 1 {
            // 输出命令行不换行
            print("Sorry: Can't find the meaning of \(originalKeyword).\nAre you looking for\n\(keyword) : \(meaning ?? "")", terminator: "")
            print("\n")
        } else {
            print("Sorry: Can't find the meaning of\(originalKeyword).")
        }
        
        //使用sqlite3数据库的C语言接口， 轻松将TXT转换为数据库文件，数据库搜索支持模糊搜索并且速度更快
        SQLiteHelper.shareHelper.writeOxfordDictionaryToDatabase(oxfordDict: dataArr.copy() as! NSArray)
    }
}

