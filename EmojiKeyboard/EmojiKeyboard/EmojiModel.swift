//
//  EmojiModel.swift
//  EmojiKeyboard
//
//  Created by Tiny on 2018/12/14.
//  Copyright © 2018年 hxq. All rights reserved.
//

import UIKit

@objcMembers
class EmojiModel: NSObject {

    var chs: String?
    var png: String?{
        didSet{
            if let png = png {
                if let path = Bundle.main.path(forResource: "EmojiKeyBoard.bundle", ofType: nil){
                    pngPath = path + "/" + png
                }
                
            }
        }
    }
    var code: String?{
        didSet{
            if let code = code{
                //创建扫描器
                let scanner = Scanner(string: code)
                var result: UInt32 = 0
                //利用扫描器扫出结果
                scanner.scanHexInt32(&result)
                //将结果转换成字符
                let c = Character(UnicodeScalar(result)!)
                //将字符转换成字符串
                emojiCode = String(c)
            }
        }
    }
    
    /// emoji表情解析后的code码
    var emojiCode: String?
    
    /// 图片的绝对路径
    var pngPath: String?
    
    /// 是否是移除键
    var isDelete: Bool = false
    
    /// 是否是空格
    var isSpace: Bool = false
    
     init(dict: [String: String]) {
        super.init()
        
        setValuesForKeys(dict)

    }
    
    init(isDelete: Bool) {
        super.init()
        self.isDelete = true
    }
    
    init(isSpace: Bool) {
        super.init()
        self.isSpace = true
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
