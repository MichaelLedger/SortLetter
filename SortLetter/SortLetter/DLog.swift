//
//  DLog.swift
//  SortLetter
//
//  Created by MountainX on 2019/2/26.
//  Copyright © 2019 MTX Software Technology Co.,Ltd. All rights reserved.
//

import Foundation

//封装的日志输出功能（T表示不指定日志信息参数类型）
func DLog<T>(_ message:T, file:String = #file, function:String = #function,
              line:Int = #line) {
    #if DEBUG
    //获取当前时间
    let now = Date()
    
    // 创建一个日期格式器
    let dformatter = DateFormatter()
    dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    
    //获取文件名
    let fileName = (file as NSString).lastPathComponent
    //打印日志内容
    print("\(dformatter.string(from: now)) \(fileName):\(line) \(function) | \(message)")
    #endif
}
