//
//  EmojiCollectionView.swift
//  EmojiKeyboard
//
//  Created by Tiny on 2018/12/14.
//  Copyright © 2018年 hxq. All rights reserved.
//

import UIKit

let row: Int = 4   //行
let col: Int = 8   //列

let screenWidth = UIScreen.main.bounds.size.width


class EmojiView: UIView {
    
    /// 表情键盘点击回调block
    var emojiBlock: ((EmojiModel)->Void)?
    
    lazy var emojiManager: EmojiManager = {
       let manager = EmojiManager.shared
        return manager
    }()
    
    lazy var collectionView: UICollectionView = {[unowned self] in
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: EmojiFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.backgroundColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha:1)
        return collectionView
    }()
    
    lazy var pageControl: UIPageControl = {
       let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .blue
        pageControl.currentPageIndicatorTintColor = .red
        return pageControl
    }()
    
    init(frame: CGRect,selectedEmoji:((EmojiModel)->Void)?) {
        super.init(frame: frame)
        emojiBlock = selectedEmoji
        setupUI()
        scrollViewDidEndDecelerating(collectionView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI(){
        
        let width = UIScreen.main.bounds.size.width/CGFloat(col)
        let height = width*CGFloat(row)
    
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(height)
        }
        
        addSubview(pageControl)
        addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom)
            make.height.equalTo(20)
        }
        
        let v = UIView()
        addSubview(v)
        v.backgroundColor = .blue
        v.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(pageControl.snp.bottom)
        }
        
    }
}

extension EmojiView: UICollectionViewDelegate,UICollectionViewDataSource {
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
    
    /// 结束拖拽
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let section = collectionView.numberOfSections
        var lastPage = 0
        for i in 0..<section {
            //每组有多少个item
            let count = collectionView.numberOfItems(inSection: i)
            //每组有多少个页
            let page = count/(row*col)
            //当前在第几组
            //一共有多少页
            lastPage = lastPage + page
        }
        //当前第多少页
        let currentPage = Int(scrollView.contentOffset.x/screenWidth)
        
        pageControl.currentPage = currentPage
        pageControl.numberOfPages = lastPage
    }
}

class EmojiFlowLayout: UICollectionViewFlowLayout {
    
    var attributesArr: [UICollectionViewLayoutAttributes] = []
    var lastPage: Int = 0

    override func prepare() {
        super.prepare()
        

        //设置宽高
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
        let width = screenWidth/CGFloat(col)
        itemSize = CGSize(width: width, height: width)
        let bmHeight = collectionView!.bounds.size.height - width*CGFloat(row)
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: bmHeight, right: 0)
        collectionView?.isPagingEnabled = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        
        var page = 0
        //获取section的数量
        let section = collectionView?.numberOfSections ?? 0
        lastPage = 0
        for i in 0..<section {
            
            //获取每页item的个数
            let count = collectionView?.numberOfItems(inSection: i) ?? 0
            for index in 0..<count{
                let indexPath = IndexPath(row: index, section: i)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                //当前在第几页
                page = index / (row*col) + lastPage
                //当前第多少行
                let r = index/col%row
                //当前第多少列
                let c = index%col
                
//                print("r = \(r) ----> c = \(c) ----> page = \(page)")
                
                let x = CGFloat(page)*screenWidth + CGFloat(c)*width
                let y = CGFloat(r)*width
                
                attributes.frame = CGRect(x: x, y: y, width: width, height: width)
                // 把每一个新的属性保存起来
                attributesArr.append(attributes)
//                print(attributes)
            }
            lastPage = lastPage + count/(row*col)
        }
    }
    
    override var collectionViewContentSize: CGSize{
        let size: CGSize = super.collectionViewContentSize
        return CGSize(width: CGFloat(lastPage)*screenWidth, height: size.height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attributesArr
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

