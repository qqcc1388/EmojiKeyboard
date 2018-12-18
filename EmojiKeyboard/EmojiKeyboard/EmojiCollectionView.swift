//
//  EmojiCollectionView.swift
//  EmojiKeyboard
//
//  Created by Tiny on 2018/12/14.
//  Copyright © 2018年 hxq. All rights reserved.
//

import UIKit

class EmojiCollectionView: UICollectionView {
    
    lazy var emojiManager: EmojiManager = {
       let manager = EmojiManager.shared
        return manager
    }()
    
    /// 表情键盘点击回调block
    var emojiBlock: ((EmojiModel)->Void)?
    
    init(frame: CGRect,selectedEmoji:((EmojiModel)->Void)?) {
        super.init(frame: frame, collectionViewLayout: EmojiFlowLayout())
        delegate = self
        dataSource = self
        register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        emojiBlock = selectedEmoji
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension EmojiCollectionView: UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojiManager.emojiPackages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let emojiPackage = emojiManager.emojiPackages[section]
        return emojiPackage.emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        let emojiPackage = emojiManager.emojiPackages[indexPath.section]
        let model = emojiPackage.emojis[indexPath.row]
        cell.model = model
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emojiPackage = emojiManager.emojiPackages[indexPath.section]
        let model = emojiPackage.emojis[indexPath.row]
        emojiBlock?(model)
    }
}

class EmojiFlowLayout: UICollectionViewFlowLayout {
    
    let row: Int = 4   //行
    let col: Int = 8   //列
    
    override func prepare() {
        super.prepare()
        
        //设置宽高
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
        let width = UIScreen.main.bounds.size.width/CGFloat(col)
        itemSize = CGSize(width: width, height: width)
        let bmHeight = collectionView!.bounds.size.height - width*CGFloat(row)
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: bmHeight, right: 0)
        collectionView?.isPagingEnabled = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
}

class EmojiCell: UICollectionViewCell {
    
    var model: EmojiModel? {
        didSet{
            emojiBtn.setImage(UIImage(contentsOfFile: model?.pngPath ?? ""), for: .normal)
            emojiBtn.setTitle(model?.emojiCode, for: .normal)
            if  let model = model {
                if model.isDelete{
                    
                    emojiBtn.setImage(UIImage(contentsOfFile: EmojiManager.shared.deletePath ?? ""), for: .normal)
                }
                if model.isSpace{
                }
            }
        }
    }
    
    lazy var emojiBtn: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        button.isUserInteractionEnabled = false

        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI(){
        contentView.addSubview(emojiBtn)
        emojiBtn.snp.makeConstraints { (maek) in
            maek.edges.equalToSuperview()
        }
    }
}

