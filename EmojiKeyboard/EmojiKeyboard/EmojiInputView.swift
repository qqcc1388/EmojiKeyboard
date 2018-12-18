//
//  EmojiInputView.swift
//  EmojiKeyboard
//
//  Created by Tiny on 2018/12/7.
//  Copyright © 2018年 hxq. All rights reserved.
//

import UIKit
import SnapKit

class EmojiInputView: UIControl {

    /// 点击键盘发送block回调
    var emojiReturnBlock: ((String)->Void)?
    
    /// 输入框上一次的高度
    private var last: CGFloat = 30
    
    private let keyBoardDefaultHeight: CGFloat = 30
    private let keyBoardMaxheight: CGFloat = 60
    private let emojiViewHeight: CGFloat = 200
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 14)
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.returnKeyType = .send
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.backgroundColor = .white
        return textView
    }()
    
    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.font = textView.font
        return label
    }()
    
    private lazy var emojiBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "Input_icon_expression"), for: .normal)
        btn.setImage(UIImage(named: "Input_icon_keyboard"), for: .selected)
        btn.addTarget(self, action: #selector(keyboardExchange(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var sendBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "input_icon_comment"), for: .normal)
        btn.setImage(UIImage(named: "input_icon_comment"), for: .selected)
        btn.addTarget(self, action: #selector(sendEmojiContent), for: .touchUpInside)
        return btn
    }()

    private lazy var emojiView: EmojiCollectionView = {
        let size = UIScreen.main.bounds.size
        let v = EmojiCollectionView(frame: CGRect(x: 0, y: 0, width: size.width, height: emojiViewHeight)){ [weak self] model in
            self?.showEmojiText(emojModel: model)
        }
        v.backgroundColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha:1)
        return v
    }()
    
    init(frame: CGRect, emojiReturn: ((String)->Void)?) {
        super.init(frame: frame)
        emojiReturnBlock = emojiReturn
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup(){
        //监听键盘的弹起和落下
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    private func setupUI(){
        
        //设置配置
        setup()
        //设置UI
        backgroundColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha:1)

        addSubview(textView)
        addSubview(emojiBtn)
        addSubview(sendBtn)
        addSubview(emojiView)
        
        //textView
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.bottom.equalTo(-5)
            make.top.equalTo(5)
            make.height.greaterThanOrEqualTo(keyBoardDefaultHeight)
            make.height.lessThanOrEqualTo(keyBoardMaxheight)
        }
    
        //emojiBtn
        emojiBtn.snp.makeConstraints { (make) in
            make.left.equalTo(textView.snp.right).offset(10)
            make.bottom.equalTo(-5)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        //sendBtn
        sendBtn.snp.makeConstraints { (make) in
            make.left.equalTo(emojiBtn.snp.right).offset(10)
            make.bottom.equalTo(-5)
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.right.equalTo(-10)
        }
        
        emojiView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(emojiViewHeight)
            make.height.equalTo(emojiViewHeight)
        }
        
        let topLine = UIView()
        topLine.backgroundColor = UIColor.lightGray
        addSubview(topLine)
        topLine.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(0)
            make.height.equalTo(0.3)
        }
        
        let bmLine = UIView()
        bmLine.backgroundColor = UIColor.lightGray
        addSubview(bmLine)
        bmLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(0.3)
        }
    }
    
    //MARK:- 表情键盘输入解析
    private func showEmojiText(emojModel: EmojiModel){
        //删除键
        if emojModel.isDelete{
            self.textView.deleteBackward()
            return
        }
        //空格键
        if emojModel.isSpace{
            return
        }
        //获取emoji并显示UITextView上
        if emojModel.emojiCode != nil {
            //找到光标的位置
            let textRange = textView.selectedTextRange
            textView.replace(textRange!, withText: emojModel.emojiCode!)
            return
        }
        // 本地图片
        let font = textView.font!
        let range = textView.selectedRange
        if emojModel.pngPath != nil {
            let attr = NSMutableAttributedString(attributedString: textView.attributedText)
            let attach = EmojiAttachment()
            attach.chs = emojModel.chs
            attach.image = UIImage(contentsOfFile: emojModel.pngPath!)
            attach.bounds = CGRect(x: 0, y: -4, width: font.lineHeight, height: font.lineHeight)
            //在光标所在位置插入表情
            attr.replaceCharacters(in: range, with: NSAttributedString(attachment: attach))
            textView.attributedText = attr
        }
        //重新设置字体大小
        textView.font = font
        
        //让选中的rang+1
        textView.selectedRange = NSRange(location: range.location+1, length: 0)
        
//        _ = textView(textView, shouldChangeTextIn: range, replacementText: "")
        
        //主动调用textDidChange方法
        textViewDidChange(textView)
    }
    
    //MARK:- 表情键盘按钮点击
    @objc private func keyboardExchange(_ btn: UIButton){
        btn.isSelected = !btn.isSelected
        //键盘切换
        if textView.isFirstResponder{
            textView.resignFirstResponder()
        }
        if btn.isSelected {  //表情键盘
            UIView.animate(withDuration: 0.25) {
                self.transform = CGAffineTransform(translationX: 0, y: -self.emojiViewHeight)
                self.emojiView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }else{  //自定义键盘
            textView.becomeFirstResponder()
        }
    }
    
    //MARK:- 点击发送表情
    @objc private func sendEmojiContent(){
        
        let attr = NSMutableAttributedString(attributedString: textView.attributedText)
        
        if attr.length == 0 {
            return
        }
        
        attr.enumerateAttributes(in: NSRange(location: 0, length: textView.attributedText.length), options: []) { (dict, range, _) in
            //替换表情图片为对应的chs
            if let attach = dict[NSAttributedString.Key.init(rawValue: "NSAttachment")] as? EmojiAttachment {
                attr.replaceCharacters(in: range, with: attach.chs!)
            }
        }
        //将输入信息发送出去
        emojiReturnBlock?(attr.string)
        //清空输入框
        textView.text = ""
        textViewDidChange(textView)
    }
    
    //MARK:- 键盘弹起
    @objc func keyBoardWillShow(_ noti: Notification){
        
        let info = noti.userInfo
        let rect = (info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //键盘偏移量
        let changeY = rect.size.height
                //键盘弹出的时间
        let duration = info?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(translationX: 0, y: -changeY)
        }
        if !emojiBtn.isSelected{
            //键盘升起来的时候让emojiView弹下去
            UIView.animate(withDuration: duration) {
                self.emojiView.transform = CGAffineTransform(translationX: 0, y: changeY)
            }
        }
    }
    //MARK:- 键盘落下
    @objc func keyBoardWillHide(_ noti: Notification){
        let info = noti.userInfo
        
        //键盘弹出的时间
        let duration = info?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform.identity
        }
        if emojiBtn.isSelected{
            UIView.animate(withDuration: duration) {
                self.transform = CGAffineTransform(translationX: 0, y: -self.emojiViewHeight)
                self.emojiView.transform = CGAffineTransform.identity
            }
        }
    }
    
    //MARK:- 关闭键盘 这方法一定使用 让键盘退下
    func closeEmojikeyBoard(){
        if textView.isFirstResponder{
            textView.resignFirstResponder()
        }
        if emojiBtn.isSelected {  //表情键盘
            UIView.animate(withDuration: 0.25) {
                self.transform = CGAffineTransform.identity
                self.emojiView.transform = CGAffineTransform.identity
            }
        }
        emojiBtn.isSelected = false
    }
    
    /// 让超出父视图部分有点击事件
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == nil {
            for subview in emojiView.subviews {
                let myPoint = subview.convert(point, from: self)
                if subview.bounds.contains(myPoint){
                    return subview
                }
            }
        }

        return view;
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension EmojiInputView: UITextViewDelegate{
    
    //监听输入
    func textViewDidChange(_ textView: UITextView) {
        //内容改变 计算文字高度 同时更新键盘的高度
        let height = textHeight()
        if textHeight() <= keyBoardMaxheight {
            textView.isScrollEnabled = false
        }else{
            textView.isScrollEnabled = true
        }
        if height != last {
            last = height
            /// 重新布局防止layout高度不生效
            textView.setNeedsUpdateConstraints()
            if textView.isScrollEnabled{
                /// 当高度超出最大高度后每次都滚动到最后一行
                textView.scrollRangeToVisible(NSRange(location: textView.attributedText.length, length: 1))
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{  //点击了发送按钮
            sendEmojiContent()
            return false
        }
        return true
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if emojiBtn.isSelected {
            emojiBtn.isSelected = true
            keyboardExchange(emojiBtn)
        }
        return true
    }
    
    //计算textView内容高度
    private func textHeight() ->  CGFloat{
        let rect = textView.attributedText.boundingRect(with: CGSize(width: textView.bounds.size.width - textView.textContainer.lineFragmentPadding*2, height: CGFloat.greatestFiniteMagnitude) , options: .usesLineFragmentOrigin, context: nil)
        return rect.height + textView.textContainerInset.top*2
    }
    
}
