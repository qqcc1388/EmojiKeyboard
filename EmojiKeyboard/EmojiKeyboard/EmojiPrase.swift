//
//  EmojiPrase.swift
//  EmojiKeyboard
//
//  Created by Tiny on 2018/12/17.
//  Copyright © 2018年 hxq. All rights reserved.
//

import UIKit

class EmojiPrase: NSObject {

    /// lineHeight 文字单行高度
    static func findEmojiAttr(emojiText: String, font: UIFont) -> NSMutableAttributedString?{
        //将emojiText转换成富文本
        // 1234[哈哈] ,将哈哈解析出来
        let pattern = "\\[.*?\\]"
        
        guard let regular = try? NSRegularExpression(pattern: pattern, options: []) else{
            return nil
        }
        let attr = NSMutableAttributedString(string: emojiText)

        let results = regular.matches(in: emojiText, options: [], range: NSRange(location: 0, length: attr.length))
        
        //从后往前遍历
        for result in results.reversed(){
            //将字符串截取出来
            let chs = (emojiText as NSString).substring(with: result.range)
            
            //将字符串截出来然后匹配
            if let pngPath = findChsPngPath(chs: chs){
                let attach = NSTextAttachment()
                attach.image = UIImage(contentsOfFile: pngPath)
                attach.bounds =  CGRect(x: 0, y: -4, width: font.lineHeight, height: font.lineHeight)
                attr.replaceCharacters(in: result.range, with: NSAttributedString(attachment: attach))
            }
        }
        return attr
    }
    
    /// 查询chs到表情库中
    private static func findChsPngPath(chs: String) -> String?{
        let manager = EmojiManager.shared
        for package in manager.emojiPackages {
            for emoji in package.emojis{
                if chs == emoji.chs{
                    return emoji.pngPath
                }
            }
        }
        return nil
    }
}
