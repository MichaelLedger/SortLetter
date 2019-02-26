//
//  ViewController.swift
//  SortLetter
//
//  Created by MountainX on 2019/2/21.
//  Copyright © 2019 MTX Software Technology Co.,Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, GameViewDelegate {
    
    // MARK: - Property
    let MARGINE:CGFloat = 10
    let BUTTON_SIZE:CGFloat = 48
    let BUTTON_ALPHA:CGFloat = 0.4
    let TOOLBAR_HEIGHT:CGFloat = 44
    var screenWidth:CGFloat!
    var screenHeight:CGFloat!
    var gameView:GameView!
    var bgMusicPlayer:AVAudioPlayer!
    var speedShow:UILabel!
    var scoreShow:UILabel!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        createDictionary()
//        searchWord(keyword: "YncHroN")
        
        startTetris()
    }
    
    // MARK: - 俄罗斯方块 Tetris
    func startTetris() {
        view.backgroundColor = UIColor.white
        
        let rect = UIScreen.main.bounds
        screenWidth = rect.size.width
        screenHeight = rect.size.height
        
        addToolBar()
        
        let gameRect = CGRect(x: rect.origin.x + MARGINE, y: rect.origin.y + TOOLBAR_HEIGHT + MARGINE*2, width: rect.size.width - MARGINE*2, height: rect.size.height - BUTTON_SIZE * 2 - TOOLBAR_HEIGHT)
        gameView = GameView(frame: gameRect)
        gameView.delegate = self
        self.view.addSubview(gameView)
        
        gameView.startGame()
    
        addButtons()
        
        //添加背景音乐
        let bgMusicUrl = Bundle.main.url(forResource: "1757", withExtension: "mp3")
        
        do
        {
            try bgMusicPlayer = AVAudioPlayer(contentsOf: bgMusicUrl!)
        } catch {
            
        }
        bgMusicPlayer.numberOfLoops = -1
        bgMusicPlayer.play()
    }
    
    func addToolBar()
    {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: MARGINE*2, width: screenWidth, height: TOOLBAR_HEIGHT))
        self.view.addSubview(toolBar)
        
        //创建一个显示速度的标签
        let speedLabel = UILabel()
        speedLabel.frame = CGRect(x: 0,y: 0,width: 50, height: TOOLBAR_HEIGHT)
        speedLabel.text = "速度:"
        let speedLabelItem = UIBarButtonItem(customView: speedLabel)
        
        //创建第二个显示速度值得标签
        speedShow = UILabel()
        speedShow.frame = CGRect(x: 0,y: 0,width: 20,height: TOOLBAR_HEIGHT)
        speedShow.textColor = UIColor.red
        let speedShowItem = UIBarButtonItem(customView: speedShow)
        
        //创建第三个显示当前积分的标签
        let scoreLabel = UILabel()
        scoreLabel.frame = CGRect(x: 0,y: 0, width: 90, height: TOOLBAR_HEIGHT)
        scoreLabel.text = "当前积分:"
        let scoreLabelItem = UIBarButtonItem(customView: scoreLabel)
        
        //创建第四个显示当前积分值标签
        scoreShow = UILabel()
        scoreShow.frame = CGRect(x: 0, y: 0,width:  40,height: TOOLBAR_HEIGHT)
        scoreShow.textColor = UIColor.red
        let scoreShowItem = UIBarButtonItem(customView: scoreShow)
        
        let flexItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.items = [speedLabelItem,speedShowItem,flexItem,scoreLabelItem,scoreShowItem]
    }
    
    //定义方向
    func addButtons()
    {
        
        //left
        let leftBtn = UIButton()
        leftBtn.frame = CGRect(x: screenWidth - BUTTON_SIZE*3 - MARGINE, y: screenHeight - BUTTON_SIZE - MARGINE, width: BUTTON_SIZE, height: BUTTON_SIZE)
        leftBtn.alpha = BUTTON_ALPHA
        leftBtn.setTitle("←", for: UIControl.State.normal)
        leftBtn.setTitleColor(UIColor.orange, for: UIControl.State.normal)
        leftBtn.addTarget(self, action: #selector(left(sender:)), for: .touchUpInside)
        self.view.addSubview(leftBtn)
        
        //up
        let upBtn = UIButton()
        upBtn.frame = CGRect(x: screenWidth - BUTTON_SIZE*2 - MARGINE, y: screenHeight - BUTTON_SIZE*2 - MARGINE, width: BUTTON_SIZE, height: BUTTON_SIZE)
        upBtn.alpha = BUTTON_ALPHA
        upBtn.setTitle("↑", for: UIControl.State.normal)
        upBtn.setTitleColor(UIColor.orange, for: UIControl.State.normal)
        upBtn.addTarget(self, action: #selector(up(sender:)), for: .touchUpInside)
        self.view.addSubview(upBtn)
        
        //right
        let rightBtn = UIButton()
        rightBtn.frame = CGRect(x: screenWidth - BUTTON_SIZE - MARGINE, y: screenHeight - BUTTON_SIZE - MARGINE, width: BUTTON_SIZE, height: BUTTON_SIZE)
        rightBtn.alpha = BUTTON_ALPHA
        rightBtn.setTitle("→", for: .normal)
        rightBtn.setTitleColor(UIColor.orange, for: .normal)
        rightBtn.addTarget(self, action: #selector(right(sender:)), for: .touchUpInside)
        self.view.addSubview(rightBtn)
        
        //down
        let downBtn = UIButton()
        downBtn.frame = CGRect(x: screenWidth - BUTTON_SIZE*2 - MARGINE, y: screenHeight - BUTTON_SIZE - MARGINE, width: BUTTON_SIZE, height: BUTTON_SIZE)
        downBtn.alpha = BUTTON_ALPHA
        downBtn.setTitle("↓", for: .normal)
        downBtn.setTitleColor(UIColor.orange, for: .normal)
        downBtn.addTarget(self, action: #selector(down(sender:)), for: .touchUpInside)
        self.view.addSubview(downBtn)
        
    }
    
    @objc func left(sender:UIButton)
    {
        gameView.moveLeft()
    }
    
    @objc func up(sender:UIButton)
    {
        gameView.rotate()
    }
    
    @objc func right(sender:UIButton)
    {
        gameView.moveRight()
    }
    
    @objc func down(sender:UIButton)
    {
        gameView.moveDown()
    }
    
    // MARK:- GameViewDelegate
    func updateScore(score: Int) {
        //跟新分数
        self.scoreShow.text = "\(score)"
    }
    
    func updateSpeed(speed: Int) {
        //跟新速度
        self.speedShow.text = "\(speed)"
    }

    
    // MARK: - 从牛津简明英汉词库中检索单词
    func searchWord(keyword: String) {
        DLog(keyword)
        let response: (word: String, mean: String?, exact: Bool) = SQLiteHelper.shareHelper.searchFromOxfordDict(keyword: keyword)
        if (response.mean != nil) && response.exact {
            DLog("Find it!\n\(response.word) : \(response.mean!)")
        } else if (response.mean != nil) && !response.exact {
            DLog("Sorry: Can't find the meaning of \(keyword).\nAre you looking for\n\(response.word) : \(response.mean!)")
        } else {
            DLog("Sorry: Can't find the meaning of \(keyword).")
        }
    }
    
    // MARK: - 读取本地txt文档并存储到数据库中(用于生成牛津简明英汉字典数据库)
    func createDictionary() {
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

