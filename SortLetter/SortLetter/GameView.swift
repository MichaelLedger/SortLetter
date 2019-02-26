//
//  GameView.swift
//  SortLetter
//
//  Created by MountainX on 2019/2/26.
//  Copyright © 2019 MTX Software Technology Co.,Ltd. All rights reserved.
//

import UIKit
import AVFoundation

protocol GameViewDelegate
{
    func updateScore(score:Int)
    func updateSpeed(speed:Int)
}

class GameView: UIView {

    var delegate:GameViewDelegate!
    //行
    var TETRIS_ROWS = 22
    let TETRIS_COLS = 15
    let CELL_SIZE :Int
    //定义绘制网格的笔触的粗细
    let STROKE_WIDTH :Double = 1.0
    let BASE_SPEED: Double = 0.6
    // 没方块是0
    let NO_BLOCK = 0
    var ctx : CGContext!
    //定义消除音乐的对象
    var displayer: AVAudioPlayer!
    //定义一个实例，代表内存中的图片
    var image: UIImage!
    //当前的计时器
    var curTimer: Timer!
    //定义方块的颜色
    let colors = [UIColor.white.cgColor,
                  UIColor.red.cgColor,
                  UIColor.green.cgColor ,
                  UIColor.blue.cgColor ,
                  UIColor.yellow.cgColor ,
                  UIColor.magenta.cgColor ,
                  UIColor.purple.cgColor ,
                  UIColor.brown.cgColor]
    
    //定义几种可能出现的方块组合
    var blockArr: [[Block]]
    
    var tetris_status = [[Int]]()
    var currentFall: [Block]!
    var curScore :Int = 0
    var curSpeed = 1
    
    
    override init(frame: CGRect) {
        
        
        self.blockArr = [
            // 代表第一种可能出现的方块组合：Z
            [
                Block(x: TETRIS_COLS / 2 - 1 , y:0 , color:1),
                Block(x: TETRIS_COLS / 2 , y:0 ,color:1),
                Block(x: TETRIS_COLS / 2 , y:1 ,color:1),
                Block(x: TETRIS_COLS / 2 + 1 , y:1 , color:1)
            ],
            // 代表第二种可能出现的方块组合：反Z
            [
                Block(x: TETRIS_COLS / 2 + 1 , y:0 , color:2),
                Block(x: TETRIS_COLS / 2 , y:0 , color:2),
                Block(x: TETRIS_COLS / 2 , y:1 , color:2),
                Block(x: TETRIS_COLS / 2 - 1 , y:1 , color:2)
            ],
            // 代表第三种可能出现的方块组合： 田
            [
                Block(x: TETRIS_COLS / 2 - 1 , y:0 , color:3),
                Block(x: TETRIS_COLS / 2 , y:0 ,  color:3),
                Block(x: TETRIS_COLS / 2 - 1 , y:1 , color:3),
                Block(x: TETRIS_COLS / 2 , y:1 , color:3)
            ],
            // 代表第四种可能出现的方块组合：L
            [
                Block(x: TETRIS_COLS / 2 - 1 , y:0 , color:4),
                Block(x: TETRIS_COLS / 2 - 1, y:1 , color:4),
                Block(x: TETRIS_COLS / 2 - 1 , y:2 , color:4),
                Block(x: TETRIS_COLS / 2 , y:2 , color:4)
            ],
            // 代表第五种可能出现的方块组合：J
            [
                Block(x: TETRIS_COLS / 2  , y:0 , color:5),
                Block(x: TETRIS_COLS / 2 , y:1, color:5),
                Block(x: TETRIS_COLS / 2  , y:2, color:5),
                Block(x: TETRIS_COLS / 2 - 1, y:2, color:5)
            ],
            // 代表第六种可能出现的方块组合 : 条
            [
                Block(x: TETRIS_COLS / 2 , y:0 , color:6),
                Block(x: TETRIS_COLS / 2 , y:1 , color:6),
                Block(x: TETRIS_COLS / 2 , y:2 , color:6),
                Block(x: TETRIS_COLS / 2 , y:3 , color:6)
            ],
            // 代表第七种可能出现的方块组合 : ┵
            [
                Block(x: TETRIS_COLS / 2 , y:0 , color:7),
                Block(x: TETRIS_COLS / 2 - 1 , y:1 , color:7),
                Block(x: TETRIS_COLS / 2 , y:1 , color:7),
                Block(x: TETRIS_COLS / 2 + 1, y:1 , color:7)
            ]
        ]
        
        //计算俄罗斯方块的大小
        self.CELL_SIZE = Int(frame.size.width) / TETRIS_COLS
        let shouldH = frame.size.height
        TETRIS_ROWS = Int(shouldH) / CELL_SIZE
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.orange
        //获取消除方块音效的音频文件的url
        let disMusicUrl = Bundle.main.url(forResource: "shake", withExtension: "wav")
        //创建AVAudioPlayer对象
        do
        {
            try displayer = AVAudioPlayer(contentsOf: disMusicUrl!)
        }catch
        {
            
        }
        displayer.numberOfLoops = 0
        
        // 开启内存中的绘图
        UIGraphicsBeginImageContext(self.bounds.size)
        // 获取Quartz 2D绘图的CGContextRef对象
        ctx = UIGraphicsGetCurrentContext()
        // 填充背景色
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(self.bounds)
        // 绘制俄罗斯方块的网格
        createCells(rows: TETRIS_ROWS, cols:TETRIS_COLS ,
                    cellWidth :CELL_SIZE, cellHeight:CELL_SIZE)
        image = UIGraphicsGetImageFromCurrentImageContext()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initTetrisStats()
    {
        let tmpRow = Array(repeating: NO_BLOCK, count: TETRIS_COLS)
        tetris_status = Array(repeating: tmpRow, count: TETRIS_ROWS)
        
    }
    func initBlock()
    {
        // 生成一个0~blockArr.count之间的随机数
        
        let diceFaceCount: UInt32 = UInt32(blockArr.count)
        let randomRoll = Int(arc4random_uniform(diceFaceCount))
        // 随机取出blockArr数组的某个元素作为“正在下掉”的方块组合
        currentFall = blockArr[randomRoll]
    }
    func createCells(rows:Int, cols:Int , cellWidth :Int, cellHeight:Int)
    {
        // 开始创建路径
        ctx.beginPath()
        // 绘制横向网络对应的路径
        for i in 0...TETRIS_ROWS
        {
            ctx.move(to: CGPoint(x: 0, y: i * CELL_SIZE))
            ctx.addLine(to: CGPoint(x: TETRIS_COLS * CELL_SIZE, y: i * CELL_SIZE))
        }
        // 绘制竖向网络对应的路径
        for i in 0...TETRIS_COLS
        {
            ctx.move(to: CGPoint(x: i * CELL_SIZE, y: 0))
            ctx.addLine(to: CGPoint(x: i * CELL_SIZE, y: TETRIS_ROWS * CELL_SIZE))
        }
        ctx.closePath()
        // 设置笔触颜色
        ctx.setStrokeColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        // 设置线条粗细
        ctx.setLineWidth(CGFloat(STROKE_WIDTH))
        // 绘制线条
        ctx.strokePath()
    }
    // 绘制俄罗斯方块的状态
    func drawBlock()
    {
        for i in 0..<TETRIS_ROWS
        {
            for j in 0..<TETRIS_COLS
            {
                // 有方块的地方绘制颜色
                if tetris_status[i][j] != NO_BLOCK
                {
                    // 设置填充颜色
                    ctx.setFillColor(colors[tetris_status[i][j]])
                    // 绘制矩形
                    ctx.fill(CGRect(x: CGFloat(j*CELL_SIZE
                        + STROKE_WIDTH) , y: CGFloat(i * CELL_SIZE + STROKE_WIDTH), width:
                        CGFloat(CELL_SIZE - STROKE_WIDTH * 2) , height:
                        CGFloat(CELL_SIZE - STROKE_WIDTH * 2)))
                }
                    // 没有方块的地方绘制白色
                else
                {
                    // 设置填充颜色
                    ctx.setFillColor(UIColor.white.cgColor)
                    // 绘制矩形
                    ctx.fill(CGRect(x: CGFloat(j * CELL_SIZE
                        + STROKE_WIDTH) , y: CGFloat(i * CELL_SIZE + STROKE_WIDTH), width:
                        CGFloat(CELL_SIZE - STROKE_WIDTH * 2) , height:
                        CGFloat(CELL_SIZE - STROKE_WIDTH * 2)))
                }
            }
        }
    }
    
    /**
     判断是否有一行已满
     */
    func lineFull()
    {
        
        //依次便利每一行
        for i in 0..<TETRIS_ROWS
        {
            
            var flag = true
            //遍历当前行的每一个单元格
            for j in 0..<TETRIS_COLS
            {
                
                if tetris_status[i][j] == NO_BLOCK
                {
                    flag = false
                    break
                }
                
            }
            //如果当前有全部方块了
            if flag
            {
                //将当前积分增加100
                curScore += 100
                self.delegate.updateScore(score: curScore)
                //如果当前积分达到升级极限
                if curScore >= curSpeed * curSpeed * 500
                {
                    //速度加1
                    curSpeed += 1
                    self.delegate.updateSpeed(speed: curSpeed)
                    //让原有计时器失效，开始新的计时器
                    curTimer.invalidate()
                    curTimer = Timer.scheduledTimer(timeInterval: BASE_SPEED / Double(curSpeed), target: self, selector: #selector(moveDown), userInfo: nil, repeats: true)
                }
                //把当前行上边的所有方块下移一行
                for j in stride(from: i, to: 0, by: -1)
                {
                    for k in stride(from: 0, to: TETRIS_COLS, by: 1)
                    {
                        tetris_status[j][k] = tetris_status[j-1][k]
                    }
                }
                
                //播放消除方块的音乐
                if !displayer.isPlaying
                {
                    displayer.play()
                }
                
                
            }
        }
    }
    
    @objc func moveDown()
    {
        
        //定义向下的旗标
        var canDown = true
        
        //判断当前的的滑块是不是可以下滑
        for i in 0..<currentFall.count
        {
            
            //判断是否已经到底了
            if currentFall[i].y >= TETRIS_ROWS - 1
            {
                
                canDown = false
                break
            }
            
            //判断下一个是不是有方块
            if tetris_status[currentFall[i].y + 1][currentFall[i].x] != NO_BLOCK
            {
                
                canDown = false
                break
            }
        }
        
        if canDown
        {
            
            self.drawBlock()
            //将下移前的方块白色
            for i in 0..<currentFall.count
            {
                
                let cur = currentFall[i]
                //设置填充颜色
                ctx.setFillColor(UIColor.white.cgColor)
                //绘制矩形
                ctx.fill(CGRect(x: CGFloat(cur.x * CELL_SIZE
                    + STROKE_WIDTH) , y: CGFloat(cur.y * CELL_SIZE + STROKE_WIDTH), width:
                    CGFloat(CELL_SIZE - STROKE_WIDTH * 2) , height:
                    CGFloat(CELL_SIZE - STROKE_WIDTH * 2)))
            }
            
            //遍历每个方块，控制每个方块的y坐标加1
            for i in 0..<currentFall.count
            {
                
                currentFall[i].y += 1
            }
            //将下移的每个方块的背景涂成方块的颜色
            for i in 0..<currentFall.count
            {
                
                let cur = currentFall[i]
                //设置填充颜色
                ctx.setFillColor(colors[cur.color])
                //绘制矩形
                ctx.fill(CGRect(x: CGFloat(cur.x * CELL_SIZE
                    + STROKE_WIDTH) , y: CGFloat(cur.y * CELL_SIZE + STROKE_WIDTH), width:
                    CGFloat(CELL_SIZE - STROKE_WIDTH * 2) , height:
                    CGFloat(CELL_SIZE - STROKE_WIDTH * 2)))
            }
        }
            //不能下落
        else
        {
            
            //遍历每个方块，把每个方块的值记录到tetris_status数组中
            for i in 0..<currentFall.count
            {
                let cur = currentFall[i]
                //如果有方块在最上边了，表明已经输了
                if cur.y < 2
                {
                    curTimer.invalidate()
                    //显示提示框
                    let alert = UIAlertController(title: "游戏结束", message: "游戏已经结束，请问是否重新开始", preferredStyle:.alert )
                    let cancelAction = UIAlertAction(title: "否", style: .default, handler: { (UIAlertAction) -> Void in
                        
                    })
                    let yeslAction = UIAlertAction(title: "是", style: .default, handler: { (UIAlertAction) -> Void in
                        self.startGame()
                    })
                    alert.addAction(cancelAction)
                    alert.addAction(yeslAction)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    
                    return
                    
                }
                //把每个方块当前所在的位置赋为当前方块的颜色值
                tetris_status[cur.y][cur.x] = cur.color
                
            }
            //判断是不是可消除
            lineFull()
            
            //开始新一组方块
            initBlock()
        }
        // 获取缓冲区的图片
        image = UIGraphicsGetImageFromCurrentImageContext()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        // 获取绘图上下文
        _ = UIGraphicsGetCurrentContext()
        // 将内存中的image图片绘制在该组件的左上角
        image.draw(at: CGPoint.zero)
        
    }
    
    //定义方块左移的方法
    func moveLeft()
    {
        //定义能否左移
        var canLeft = true
        for i in 0..<currentFall.count
        {
            //如果已经到了最左边
            if currentFall[i].x <= 0
            {
                canLeft = false
                break
            }
            
            //或者左边已经有方块
            if tetris_status[currentFall[i].y][currentFall[i].x - 1] != NO_BLOCK
            {
                canLeft = false
                break
            }
        }
        
        //如果能左移
        if canLeft
        {
            self.drawBlock()
            //将左移前的方块涂成白色
            for i in 0..<currentFall.count
            {
                let cur = currentFall[i]
                
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fill(CGRect(x: CGFloat(cur.x*CELL_SIZE + STROKE_WIDTH), y: CGFloat(cur.y*CELL_SIZE + STROKE_WIDTH), width:  CGFloat(CELL_SIZE - STROKE_WIDTH*2), height: CGFloat(CELL_SIZE - STROKE_WIDTH*2)))
            }
            
            //左移所有正在下降的方块
            for i in 0..<currentFall.count
            {
                currentFall[i].x -= 1
            }
            
            //将左移的方块渲染颜色
            for i in 0..<currentFall.count
            {
                let cur = currentFall[i]
                
                ctx.setFillColor(colors[cur.color])
                ctx.fill(CGRect(x: CGFloat(cur.x*CELL_SIZE + STROKE_WIDTH), y: CGFloat(cur.y*CELL_SIZE + STROKE_WIDTH), width: CGFloat(CELL_SIZE - STROKE_WIDTH*2), height: CGFloat(CELL_SIZE - STROKE_WIDTH*2)))
            }
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            
            self.setNeedsDisplay()
        }
    }
    
    //定义方块右移的方法
    func moveRight()
    {
        //定义能否右移
        var canRight = true
        for i in 0..<currentFall.count
        {
            //如果已经到了最右边
            if currentFall[i].x >= TETRIS_COLS - 1
            {
                canRight = false
                break
            }
            
            //或者右边已经有方块
            if tetris_status[currentFall[i].y][currentFall[i].x + 1] != NO_BLOCK
            {
                canRight = false
                break
            }
        }
        
        //如果能右移
        if canRight
        {
            self.drawBlock()
            //将左移前的方块涂成白色
            for i in 0..<currentFall.count
            {
                let cur = currentFall[i]
                
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fill(CGRect(x: CGFloat(cur.x*CELL_SIZE + STROKE_WIDTH), y:  CGFloat(cur.y*CELL_SIZE + STROKE_WIDTH), width: CGFloat(CELL_SIZE - STROKE_WIDTH*2), height: CGFloat(CELL_SIZE - STROKE_WIDTH*2)))
            }
            
            //右移所有正在下降的方块
            for i in 0..<currentFall.count
            {
                currentFall[i].x += 1
            }
            
            //将右移的方块渲染颜色
            for i in 0..<currentFall.count
            {
                let cur = currentFall[i]
                
                ctx.setFillColor(colors[cur.color])
                ctx.fill(CGRect(x: CGFloat(cur.x*CELL_SIZE + STROKE_WIDTH), y: CGFloat(cur.y*CELL_SIZE + STROKE_WIDTH), width:  CGFloat(CELL_SIZE - STROKE_WIDTH*2), height: CGFloat(CELL_SIZE - STROKE_WIDTH*2)))
            }
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            
            self.setNeedsDisplay()
        }
    }
    
    func rotate()
    {
        var canRotate = true
        
        for i in 0..<currentFall.count
        {
            let preX = currentFall[i].x
            let preY = currentFall[i].y
            
            if i != 2
            {
                //计算旋转后的坐标
                let afterRotateX = currentFall[2].x + preY - currentFall[2].y
                let afterRotateY = currentFall[2].y + currentFall[2].x - preX
                //如果旋转后的x。y越界或者旋转后的位置已有方块，表明不能旋转
                if afterRotateX < 0 || afterRotateX > TETRIS_COLS - 1 || afterRotateY < 0 || afterRotateY > TETRIS_ROWS - 1||tetris_status[afterRotateY][afterRotateX] != NO_BLOCK
                {
                    canRotate = false
                    break
                }
            }
        }
        
        if canRotate
        {
            for i in 0..<currentFall.count
            {
                let cur = currentFall[i]
                
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fill(CGRect(x: CGFloat(cur.x*CELL_SIZE + STROKE_WIDTH), y: CGFloat(cur.y*CELL_SIZE + STROKE_WIDTH), width: CGFloat(CELL_SIZE - STROKE_WIDTH*2), height: CGFloat(CELL_SIZE - STROKE_WIDTH*2)))
            }
            
            for i in 0..<currentFall.count
            {
                let preX = currentFall[i].x
                let preY = currentFall[i].y
                
                if i != 2
                {
                    currentFall[i].x = currentFall[2].x + preY - currentFall[2].y
                    currentFall[i].y = currentFall[2].y + currentFall[2].x - preX
                }
                
            }
            
            for i in 0..<currentFall.count
            {
                let cur = currentFall[i]
                
                ctx.setFillColor(colors[cur.color])
                ctx.fill(CGRect(x: CGFloat(cur.x*CELL_SIZE + STROKE_WIDTH), y: CGFloat(cur.y*CELL_SIZE + STROKE_WIDTH), width: CGFloat(CELL_SIZE - STROKE_WIDTH*2), height: CGFloat(CELL_SIZE - STROKE_WIDTH*2)))
            }
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            
            self.setNeedsDisplay()
        }
    }
    
    func startGame()
    {
        self.curSpeed = 1
        self.delegate.updateSpeed(speed: self.curSpeed)
        self.curScore = 0
        self.delegate.updateScore(score: self.curScore)
        
        initTetrisStats()
        
        initBlock()
        
        curTimer = Timer.scheduledTimer(timeInterval: BASE_SPEED / Double(curSpeed), target: self, selector: #selector(GameView.moveDown), userInfo: nil, repeats: true)
    }

}
