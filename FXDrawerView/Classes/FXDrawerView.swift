//
//  FXDrawerView.swift
//  FXDrawerView
//
//  Created by FuXiang on 2023/4/5.
//


/**
 
 
 **/

import UIKit

@objc public protocol FXDrawerViewDataSource: NSObjectProtocol {
    /// 获取空白位置内容
    @objc optional func drawerSpaceContentView(in drawerView: FXDrawerView) -> UIView
    /// 获取抽屉内容
    @objc optional func drawerContentView(in drawerView: FXDrawerView) -> UIView
}

@objc public protocol FXDrawerViewDelegate: NSObjectProtocol {
    /// 空白轻触执行
    @objc optional func drawerContentViewSpaceContentViewTap(in drawerView: FXDrawerView)
}

public class FXDrawerView: UIView {
    
    public enum DrawerType: Int{
        case left = 0 // 显示在左部
        case right // 显示在右部
        case top // 显示在顶部
        case bottom // 显示在底部
        case center // 显示在中心
    }
    
    public var drawerType: DrawerType = .bottom
    
    /// 拖拽使内容显示百分比，拖拽结束大于时会打开抽屉，反之关闭，中心显示模式时是中心缩放百分比
    public var scale = 0.5
    
    /// 是否开启交互穿透
    public var pierceThrough = false
    
    /// 指定控件不做穿透
    public var disablePierceThroughViews: [UIView] = []
    
    
    weak open var dataSource: FXDrawerViewDataSource?

    weak open var delegate: FXDrawerViewDelegate?
    /// 获取空白位置内容
    public var drawerSpaceContentViewBlock: ((FXDrawerView) -> UIView)?
    /// 获取抽屉内容
    public var drawerContentViewBlock: ((FXDrawerView) -> UIView)?
    /// 空白轻触执行
    public var drawerContentViewSpaceContentViewTapBlock: ((FXDrawerView) -> Void)?
    
    /// 承载spaceContentView和drawerContentView的控件
    public lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    /// 抽屉背景控件
    public lazy var spaceContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }()
        
    /// 抽屉内容控件
    public lazy var drawerContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.insertSubview(view, aboveSubview: spaceContentView)
        return view
    }()

    /// drawerContentView首部直接显示的量，正数抽屉开关前先显示一部分抽屉内容，负数相反
    public var spaceContentTrailingOffset = 0.0
    
    /// drawerContentView 和 spaceContentView 交接处重叠的量， 正数重叠，负数分离
    public var drawerContentLeadingOffset = 0.0
    
    /// drawerContentView尾部隐藏的量，正数抽屉开时有一部分不会显示，负数会全部显示并有间隙
    public var drawerContentTrailingOffset = 0.0
    
    /// 布局约束
    private var drawerConstraints: [NSLayoutConstraint] = []
    private var contentConstraints: [NSLayoutConstraint] = []
    
    /// 拖拽抽屉
    public lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
        return pan
    }()
    
    /// 轻触关闭
    public lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle(_:)))
        return tap
    }()
    
    public var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 穿透处理
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if pierceThrough {
            for view in disablePierceThroughViews {
                let convertPoint = self.convert(point, to: view)
                if (view.frame.contains(convertPoint)) {
                    return super.hitTest(point, with: event)
                }
            }
            return nil
        }
        return super.hitTest(point, with: event)
    }
    
    /// 刷新
    func reload() {
        
        removeConstraints(drawerConstraints)
        contentView.removeConstraints(contentConstraints)
        drawerConstraints = []
        contentConstraints = []
        
        for subView in spaceContentView.subviews.reversed() {
            subView.removeFromSuperview()
        }
        var spaceContent: UIView?
        if let view = dataSource?.drawerSpaceContentView?(in: self) {
            spaceContent = view
        }else if let view = self.drawerSpaceContentViewBlock?(self) {
            spaceContent = view
        }
        if let spaceContent = spaceContent {
            spaceContentView.addSubview(spaceContent)
            spaceContent.translatesAutoresizingMaskIntoConstraints = false
            contentConstraints.append(
                contentsOf: NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[spaceContent]|",
                    options: .directionMask,
                    metrics: nil,
                    views: ["spaceContent": spaceContent]))
            contentConstraints.append(
                contentsOf: NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[spaceContent]|",
                    options: .directionMask,
                    metrics: nil,
                    views: ["spaceContent": spaceContent]))
        }
        
        for subView in drawerContentView.subviews.reversed() {
            subView.removeFromSuperview()
        }
        var drawerContent: UIView?
        if let view = dataSource?.drawerContentView?(in: self) {
            drawerContent = view
        }else if let view = self.drawerContentViewBlock?(self) {
            drawerContent = view
        }
        if let drawerContent = drawerContent {
            drawerContentView.addSubview(drawerContent)
            drawerContent.translatesAutoresizingMaskIntoConstraints = false
            contentConstraints.append(
                contentsOf: NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[drawerContent]|",
                    options: .directionMask,
                    metrics: nil,
                    views: ["drawerContent": drawerContent]))
            contentConstraints.append(
                contentsOf: NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[drawerContent]|",
                    options: .directionMask,
                    metrics: nil,
                    views: ["drawerContent": drawerContent]))
        }
        if drawerType == .center {
            drawerConstraints.append(
                contentsOf: NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[content]|",
                    options: .directionMask,
                    metrics: nil,
                    views: ["content": contentView]))
            drawerConstraints.append(
                contentsOf: NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[content]|",
                    options: .directionMask,
                    metrics: nil,
                    views: ["content": contentView]))
            
            contentConstraints.append(
                contentsOf: NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[spaceContentView]|",
                    options: .directionMask,
                    metrics: nil,
                    views: ["spaceContentView": spaceContentView]))
            contentConstraints.append(
                contentsOf: NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[spaceContentView]|",
                    options: .directionMask,
                    metrics: nil,
                    views: ["spaceContentView": spaceContentView]))
            contentConstraints.append(NSLayoutConstraint(item: drawerContentView, attribute: .centerX, relatedBy: .equal, toItem: spaceContentView, attribute: .centerX, multiplier: 1.0, constant: drawerContentLeadingOffset))
            contentConstraints.append(NSLayoutConstraint(item: drawerContentView, attribute: .centerY, relatedBy: .equal, toItem: spaceContentView, attribute: .centerY, multiplier: 1.0, constant: drawerContentTrailingOffset))
            drawerContentView.transform = drawerContentView.transform.scaledBy(x: 0.0, y: 0.0)
        }else {
            if drawerType != .top {
                drawerConstraints.append(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
            }
            if drawerType != .left {
                drawerConstraints.append(NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0))
            }
            if drawerType != .bottom {
                drawerConstraints.append(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
            }
            
            if drawerType != .right {
                drawerConstraints.append(NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0))
            }
            if drawerType == .bottom || drawerType == .top{
                contentConstraints.append(
                    contentsOf: NSLayoutConstraint.constraints(
                        withVisualFormat: "H:|[spaceContentView]|",
                        options: .directionMask,
                        metrics: nil,
                        views: ["spaceContentView": spaceContentView]))
                contentConstraints.append(
                    contentsOf: NSLayoutConstraint.constraints(
                        withVisualFormat: "H:|[drawerContentView]|",
                        options: .directionMask,
                        metrics: nil,
                        views: ["drawerContentView": drawerContentView]))
                
                drawerConstraints.append(NSLayoutConstraint(item: spaceContentView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0))
            }
            
            if drawerType == .left || drawerType == .right{
                contentConstraints.append(
                    contentsOf: NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|[spaceContentView]|",
                        options: .directionMask,
                        metrics: nil,
                        views: ["spaceContentView": spaceContentView]))
                contentConstraints.append(
                    contentsOf: NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|[drawerContentView]|",
                        options: .directionMask,
                        metrics: nil,
                        views: ["drawerContentView": drawerContentView]))
                
                drawerConstraints.append(NSLayoutConstraint(item: spaceContentView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
            }
            
            if drawerType == .bottom{
                
                contentConstraints.append(NSLayoutConstraint(item: spaceContentView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: -spaceContentTrailingOffset))
                contentConstraints.append(NSLayoutConstraint(item: drawerContentView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -drawerContentTrailingOffset))
                contentConstraints.append(NSLayoutConstraint(item: drawerContentView, attribute: .top, relatedBy: .equal, toItem: spaceContentView, attribute: .bottom, multiplier: 1.0, constant: -drawerContentLeadingOffset))
            }
            if drawerType == .top {
                contentConstraints.append(NSLayoutConstraint(item: spaceContentView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: spaceContentTrailingOffset))
                contentConstraints.append(NSLayoutConstraint(item: drawerContentView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: drawerContentTrailingOffset))
                contentConstraints.append(NSLayoutConstraint(item: drawerContentView, attribute: .bottom, relatedBy: .equal, toItem: spaceContentView, attribute: .top, multiplier: 1.0, constant: drawerContentLeadingOffset))
                
            }
            if drawerType == .left {
                contentConstraints.append(NSLayoutConstraint(item: spaceContentView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: spaceContentTrailingOffset))
                contentConstraints.append(NSLayoutConstraint(item: drawerContentView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: drawerContentTrailingOffset))
                contentConstraints.append(NSLayoutConstraint(item: drawerContentView, attribute: .right, relatedBy: .equal, toItem: spaceContentView, attribute: .left, multiplier: 1.0, constant: drawerContentLeadingOffset))
            }
            if drawerType == .right {
                contentConstraints.append(NSLayoutConstraint(item: spaceContentView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: -spaceContentTrailingOffset))
                contentConstraints.append(NSLayoutConstraint(item: drawerContentView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -drawerContentTrailingOffset))
                contentConstraints.append(NSLayoutConstraint(item: drawerContentView, attribute: .left, relatedBy: .equal, toItem: spaceContentView, attribute: .right, multiplier: 1.0, constant: -drawerContentLeadingOffset))
                
            }
        }
        contentView.addConstraints(contentConstraints)
        addConstraints(drawerConstraints)
    }
    
    /// 点击事件处理
    @objc func tapHandle(_ recognizer : UITapGestureRecognizer) {
        drawerContentViewSpaceContentViewTapBlock?(self)
        delegate?.drawerContentViewSpaceContentViewTap?(in: self)
    }
    
    /// 拖拽事件处理
    @objc func panHandle(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        switch (recognizer.state) {
        case .began:
            print("begin")
        case .changed:
            var newBounds = bounds
            let maxOffsetH = max(0, contentView.bounds.height - bounds.height)
            let maxOffsetW = max(0, contentView.bounds.width - bounds.width)
            switch (drawerType) {
            case .top:
                newBounds.origin.y =  max(-maxOffsetH, min(newBounds.origin.y - translation.y, 0))
            case .left:
                newBounds.origin.x =  max(-maxOffsetW, min(newBounds.origin.x - translation.x, 0))
            case .bottom:
                newBounds.origin.y =  max(0, min(newBounds.origin.y - translation.y, maxOffsetH))
            case .right:
                newBounds.origin.x =  max(0, min(newBounds.origin.x - translation.x, maxOffsetW))
            case .center:
                var scaleValue = 0.0
                if abs(translation.x) > abs(translation.y) {
                    scaleValue = drawerContentView.transform.a - translation.x/bounds.width * 10
                }else {
                    scaleValue = drawerContentView.transform.a - translation.y/bounds.height * 10
                }
                scaleValue = max(0.0, min(scaleValue, 1))
                drawerContentView.transform = CGAffineTransform.identity.scaledBy(x: scaleValue, y: scaleValue)
            }
            bounds = newBounds
            recognizer.setTranslation(CGPoint.zero, in: self)
        case .ended:
            //加最大最小Y控制
            print("end")
            let maxOffsetH = max(0, contentView.bounds.height - bounds.height)
            let maxOffsetW = max(0, contentView.bounds.width - bounds.width)
            var needShowDrawerView = false
            switch (drawerType) {
            case .top:
                needShowDrawerView =  bounds.origin.y <= -maxOffsetH * scale
            case .left:
                needShowDrawerView = bounds.origin.x <= -maxOffsetW * scale
            case .bottom:
                needShowDrawerView = bounds.origin.y >= maxOffsetH * scale
            case .right:
                needShowDrawerView = bounds.origin.x >= maxOffsetW * scale
            case .center:
                needShowDrawerView = drawerContentView.transform.a > scale
            }
            if needShowDrawerView {
                openDrawerView()
            }else {
                closeDrawerView()
            }
        default:
            print("else")
        }

    }
    
    /// 打开抽屉
    func openDrawerView() {
        
        var newBounds = bounds
        let maxOffsetH = max(0, contentView.bounds.height - bounds.height)
        let maxOffsetW = max(0, contentView.bounds.width - bounds.width)
        switch (drawerType) {
        case .top:
            newBounds.origin.y =  -maxOffsetH
        case .left:
            newBounds.origin.x =  -maxOffsetW
        case .bottom:
            newBounds.origin.y =  maxOffsetH
        case .right:
            newBounds.origin.x =  maxOffsetW
        case .center:
            drawerContentView.transform = .identity
        }
        bounds = newBounds
    }
    
    /// 关闭抽屉
    func closeDrawerView() {
        var newBounds = bounds
        switch (drawerType) {
        case .top:
            newBounds.origin.y =  0
        case .left:
            newBounds.origin.x =  0
        case .bottom:
            newBounds.origin.y =  0
        case .right:
            newBounds.origin.x =  0
        case .center:
            drawerContentView.transform = drawerContentView.transform.scaledBy(x: 0.01, y: 0.01)
        }
        bounds = newBounds
    }
    
   
}
