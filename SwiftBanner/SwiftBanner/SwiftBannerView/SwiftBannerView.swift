//
//  SwiftBannerView.swift
//  SwiftBanner
//
//  Created by 张行 on 16/8/17.
//  Copyright © 2016年 张行. All rights reserved.
//


import UIKit
import SnapKit


public typealias SwiftBannerViewBannerImageComplete = (_:UIImageView, _:UIImage) -> Void
public typealias SwiftBannerViewBannerImageUrlComplete = (_:UIImageView, _:String) -> Void
public typealias SwiftBannerViewDidClickImageComplete = (_:SwiftBannerView, _:UIImageView, _:Int) ->Void

public class SwiftBannerView: UIView,UIScrollViewDelegate {

    //MARK: - public 属性
    public var bannerImageComplete:SwiftBannerViewBannerImageComplete? /// 本地赋值图片自定义回掉 可以实现图片的自定义

    public var bannerImageUrlComplete:SwiftBannerViewBannerImageUrlComplete? /// 网络图片的自定义的回掉 可以实现自定义的图片加载方式 当是加载网络图片的话 一定需要实现
    public var bannerImageClickComplete:SwiftBannerViewDidClickImageComplete? //点击了图片的回掉
    public var isAutoScroll:Bool = true //是否自动轮播 默认为true

    public var timeInterval:NSTimeInterval = 5 //自动轮播的时间间隔 默认为5秒

    public var maxPageCount:Int = 5// 最大支持page页显示的个数 默认为5

    private var imageScrollView:UIScrollView //显示图片的UIScrollView

    internal(set) var pageControl:UIPageControl //显示页数
    //MARK: - private 属性
    private var bannerImages:[UIImage]? //本地图片存放的数组

    private var bannerImageUrls:[String]? //网络图片地址存放的数组

    private var bannerIndex:Int = 0 //当前显示banner所在的索引 默认为0
    {
        didSet{
            self.pageControl.currentPage = self.bannerIndex
        }
    }

    private var bannerCount:Int {//baner数量
        get{
            if self.bannerImages != nil {
                return self.bannerImages!.count
            }else if self.bannerImageUrls != nil {
                return self.bannerImageUrls!.count
            }else {
                return 0
            }
        }
    }

    private var isUseCurrentIndex:Bool = false //是否使用同一张图片防止切换闪烁

    private let imageViews:[UIImageView] //存放三张图片

    private var isFirstResetImageScrollViewContent:Bool = false //是否第一次设置了图片的位置

    private var bannerTimer:NSTimer? //定时器
    // MARK: - 初始化方法

    /*!
    初始化本地图片显示

    - parameter bannerImages: 本地图片的数组
    - parameter frame:        试图的大小

    - returns: SwiftBannerView
    */
    public convenience init? (bannerImages:[UIImage]?,frame:CGRect = CGRectZero) {
        self.init(bannerImages:bannerImages, bannerImageUrls:nil, frame:frame)
    }
    /*!
    初始化网络图片显示

    - parameter bannerImageUrls: 网络图片的地址数组
    - parameter frame:           试图的大小

    - returns: SwiftBannerView
    */
    public convenience init? (bannerImageUrls:[String]?,frame:CGRect = CGRectZero) {
        self.init(bannerImages:nil, bannerImageUrls:bannerImageUrls, frame:frame)
    }

    private init (bannerImages:[UIImage]? , bannerImageUrls:[String]? , frame:CGRect = CGRectZero) {

        self.imageScrollView = UIScrollView(frame: frame)
        self.bannerImages = bannerImages
        self.bannerImageUrls = bannerImageUrls
        var tempImageViews:[UIImageView] = [UIImageView]()
        for _ in 0...2 {
            tempImageViews.append(UIImageView())
        }
        self.imageViews = tempImageViews
        self.pageControl = UIPageControl(frame: CGRectZero)
        super.init(frame: frame)

        self.imageScrollView.delegate = self
        self.imageScrollView.pagingEnabled = true // 设置只能一页一页的滑动
        self.imageScrollView.showsHorizontalScrollIndicator = false //隐藏横向的滚动条 防止出现错位
        if self.bannerCount == 1 { //如果只有一个就不让滑动
            self.imageScrollView.scrollEnabled = false
        }

        self.addSubview(self.imageScrollView)
        self.imageScrollView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        }

        let imageScrollContentView:UIView = UIView()
        self.imageScrollView.addSubview(imageScrollContentView)
        imageScrollContentView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsZero)
            make.height.equalTo(self.imageScrollView)
        }
        var upView:UIView?;
        for i in 0..<self.imageViews.count {
            let imageView:UIImageView = self.imageViews[i]
            imageView.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(SwiftBannerView.bannerImageTap(_:)))
            imageView.addGestureRecognizer(tap)
            imageScrollContentView.addSubview(imageView)
            imageView.snp_makeConstraints(closure: { (make) in
                make.top.bottom.equalTo(imageScrollContentView)
                if upView == nil {
                    make.left.equalTo(imageScrollContentView)
                }else {
                    make.left.equalTo(upView!.snp_right)
                }
                make.width.equalTo(self.imageScrollView)
            })
            upView = imageView
        }

        imageScrollContentView.snp_makeConstraints { (make) in
            make.right.equalTo(upView!)
        }


        let pageNumber = self.bannerCount > self.maxPageCount ? self.maxPageCount : self.bannerCount
        self.pageControl.numberOfPages = pageNumber

        self.addSubview(self.pageControl)
        self.pageControl.snp_makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self)
        }
    }

    @objc private func bannerImageTap(tap:UITapGestureRecognizer) {
        guard let imageView:UIImageView = tap.view as? UIImageView else {
            return
        }
        guard let complete:SwiftBannerViewDidClickImageComplete = self.bannerImageClickComplete else {
            return
        }
        guard let index = self.imageViews.indexOf(imageView) else {
            return
        }
        complete(self,imageView,index)
    }

    //MARK: -

    public override func layoutSubviews() {
        super.layoutSubviews()
        if !self.isFirstResetImageScrollViewContent { //只有第一次设置试图大小才会进行初始化操作
            self.resetImageCollectionViewContentOfSet(false)
            self.scroolBanner(false, page: 1)
            self.bannerTimer = NSTimer.scheduledTimerWithTimeInterval(self.timeInterval, target: self, selector: #selector(SwiftBannerView.autoScroll), userInfo: nil, repeats: true)
        }
    }
    /*!
     开启自动滚动
     */
    @objc private func autoScroll() {
//        print("autoScroll->>>>>>>>>>>>\(CFAbsoluteTimeGetCurrent())")
        self.bannerIndex = self.index(self.bannerIndex + 1) //获取现在需要显示的索引
        self.scroolBanner(true,page: 2) //自动滚动到对应的位置
    }
    /*!
     滚动当所在的页数

     - parameter animated: 是否有动画
     - parameter page:     所在的页数
     */
    private func scroolBanner(animated:Bool, page:CGFloat) {
        self.imageScrollView.setContentOffset(CGPointMake(self.imageScrollView.bounds.size.width * page, 0), animated: animated)
    }

    public convenience required  init?(coder aDecoder: NSCoder) {
        self.init(bannerImages:nil, bannerImageUrls:nil, frame:CGRectZero)
    }
    /*!
     重新恢复状态 滚动到中间的位置
     */
    private func resetImageCollectionViewContentOfSet() {
        self.resetImageCollectionViewContentOfSet(true) //先设置所有的图片都是同一张
        self.scroolBanner(false, page: 1) //滚动位置打牌中间
        self.resetImageCollectionViewContentOfSet(false) //重新设置图片
    }
    /*!
     重新设置图片显示框显示的图片内容

     - parameter useCurrentIndex: 是否全部使用当前的索引
     */
    private func resetImageCollectionViewContentOfSet(useCurrentIndex:Bool) {
        self.isUseCurrentIndex = useCurrentIndex;
        for  i in 0..<3 {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            self.imageViewWithIndexPath(indexPath)
        }
    }
    /*!
     根据索引设置对应的图片

     - parameter indexPath: 图片所在的位置

     - returns: 图片显示的控件
     */
    private func imageViewWithIndexPath(indexPath:NSIndexPath) -> UIImageView {
        let imageView:UIImageView = self.imageViews[indexPath.row]
        imageView.image = nil //清空之前图片显示
        var index = self.bannerIndex //获取现在图片的索引
        if indexPath.row == 0 {
            index = self.index(index - 1)
        }else if indexPath.row == 2 {
            index = self.index(index + 1)
        }
        if self.isUseCurrentIndex {
            index = self.bannerIndex
        }
        if self.bannerImages != nil { //本地图片
            let image:UIImage = self.bannerImages![index]
            imageView.image = image
            if self.bannerImageComplete != nil { //赋值自定义的显示方式
                self.bannerImageComplete!(imageView,image)
            }
        }else if (self.bannerImageUrls != nil) { //如果是网络的图片
            let imageUrl = self.bannerImageUrls![index]
            if self.bannerImageUrlComplete != nil { //自定义网络的图片加载
                self.bannerImageUrlComplete!(imageView,imageUrl)
            }
        }
        return imageView

    }
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / scrollView.bounds.size.width //获取当前的页数
        if index == 0 { // 左边的位置 索引减少
            self.bannerIndex = self.index(self.bannerIndex - 1)
        }else if index == 2 { //右边的位置 索引增加
            self.bannerIndex = self.index(self.bannerIndex + 1)
        }
        self.resetImageCollectionViewContentOfSet()
        self.bannerTimer = NSTimer.scheduledTimerWithTimeInterval(self.timeInterval, target: self, selector: #selector(SwiftBannerView.autoScroll), userInfo: nil, repeats: true)
    }

    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.bannerTimer!.invalidate()
    }

    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.resetImageCollectionViewContentOfSet() //如果自动切换动画完成 就重新设置图片的显示
    }

    // 获取索引正确的位置
    private func index(index:Int) -> Int {
        if index < 0 {
            return self.bannerCount - 1
        }else if index >= self.bannerCount {
            return 0
        }else {
            return index
        }
    }

}


