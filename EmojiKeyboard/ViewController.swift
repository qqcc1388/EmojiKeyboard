//
//  ViewController.swift
//  EmojiKeyboard
//
//  Created by Tiny on 2018/12/7.
//  Copyright © 2018年 hxq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var textLabel: UILabel!
    var emojiInput: EmojiInputView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let label = UILabel()
        label.text = "xxxx"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        textLabel = label
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(100)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        emojiInput = EmojiInputView(frame: .zero) { [weak self] (text) in
            let attr = EmojiPrase.findEmojiAttr(emojiText: text, font: (self?.textLabel.font)!)
            self?.textLabel.attributedText = attr
        }
        emojiInput.placeHolder = "请输入内容"
        
        view.addSubview(emojiInput)
        emojiInput.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        emojiInput.closeEmojikeyBoard()
//    }
}


