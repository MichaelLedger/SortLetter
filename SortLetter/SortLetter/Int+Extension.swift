//
//  Int+Extension.swift
//  SortLetter
//
//  Created by MountainX on 2019/2/21.
//  Copyright © 2019 MTX Software Technology Co.,Ltd. All rights reserved.
//

import Foundation

//(1)Swift的Int类型不在支持自增减运算符,比如 ++a —a,a—,a++的方式
//(2)如果想要Swift想要支持这种方法,必须重载运算符
extension Int {
    //前+
    static prefix func ++(num:inout Int) -> Int  {
        num += 1
        return num
    }
    //后缀+
    static postfix func ++(num:inout Int) -> Int  {
        let temp = num
        num += 1
        return temp
    }
    //前 -
    static prefix func --(num:inout Int) -> Int  {
        num -= 1
        return num
    }
    //后-
    static postfix func --(num:inout Int) -> Int  {
        let temp = num
        num -= 1
        return temp
    }
}

// 重载+运算符，让+支持Int + Double运算
func + (left: Int , right:Double) -> Double
{
    return Double(left) + right
}
// 重载-运算符，让+支持Int - Double运算
func - (left: Int , right:Double) -> Double
{
    return Double(left) - right
}
