//
//  EmojiManager.swift
//  EmojiKeyboard
//
//  Created by Tiny on 2018/12/14.
//  Copyright © 2018年 hxq. All rights reserved.
//  管理emoji

import UIKit

class EmojiManager: NSObject {

    static let shared: EmojiManager = EmojiManager()
    
    var emojiPackages = [EmojiPackage]()
    
    var deletePath: String?
    
    override init() {
        super.init()
        //加载Emoji
        guard let path = Bundle.main.path(forResource: "emojiPackage.plist", ofType: nil, inDirectory: "EmojiKeyBoard.bundle") else{
            return
        }
        guard let dict = NSDictionary(contentsOfFile: path) as? [String:Any] else{
            return
        }
        
        guard let array = dict["packages"] as? [[String:String]] else{
            return
        }
        for dict  in array {
           emojiPackages.append(EmojiPackage(dict: dict))
        }
        
        //deletePath
        guard let deletePath = Bundle.main.path(forResource: "delete@3x.png", ofType: nil, inDirectory: "EmojiKeyBoard.bundle") else{
            return
        }
        self.deletePath = deletePath
    }
}
