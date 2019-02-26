//
//  Finger.swift
//  SortLetter
//
//  Created by MountainX on 2019/2/26.
//  Copyright © 2019 MTX Software Technology Co.,Ltd. All rights reserved.
//

import UIKit

class Finger: UIView {

    var curX:CGFloat = 0
    var curY:CGFloat = 0
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject = (touches as NSSet).anyObject() as AnyObject
        let lastTouch = touch.location(in: self)
        curX = lastTouch.x
        curY = lastTouch.y
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(UIColor.red.cgColor)
        ctx?.fillEllipse(in: CGRect(x: curX-10, y: curY-10, width: 20, height: 20))
    }

}
