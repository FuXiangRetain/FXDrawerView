//
//  FXDrawerView_Ext.swift
//  FXDrawerView
//
//  Created by FuXiang on 2023/4/5.
//

import UIKit

/// 获取keyWindow
public func FxGetKeyWindow() -> UIWindow? {
    var window:UIWindow?
    if #available(iOS 13, *) {
        if #available(iOS 15, *) {
            window = UIApplication.shared.connectedScenes
                        .map({ $0 as? UIWindowScene })
                        .compactMap({ $0 })
                        .first?.windows.first
        }else{
            window = UIApplication.shared.windows.first
        }
    }else{
       window = UIApplication.shared.keyWindow
    }
    return window
}


class FXToastView: UIView {
    
    lazy var magLab: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.translatesAutoresizingMaskIntoConstraints = false
        
        return lab
    }()
    
    lazy var msgContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.addSubview(magLab)
        view.layer.cornerRadius = 22
        view.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            magLab.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            magLab.topAnchor.constraint(equalTo: view.topAnchor),
            magLab.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            magLab.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            magLab.heightAnchor.constraint(equalToConstant: 44)
        ])
        addSubview(view)
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let safeArea = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            msgContentView.leftAnchor.constraint(greaterThanOrEqualTo: safeArea.leftAnchor, constant: 16),
            msgContentView.topAnchor.constraint(greaterThanOrEqualTo: safeArea.topAnchor, constant: 16),
            msgContentView.rightAnchor.constraint(lessThanOrEqualTo: safeArea.rightAnchor, constant: -16),
            msgContentView.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor, constant: -16),
            msgContentView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            msgContentView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension FXDrawerView {
    
    /// 创建一个静态抽屉
    class public func createDrawer(
        drawerType: DrawerType = .bottom,
        spaceContentTrailingOffset: Double = 0.0,
        drawerContentLeadingOffset: Double = 0.0,
        drawerContentTrailingOffset: Double = 0.0,
        drawerContentViewBlock: ((FXDrawerView) -> UIView)? = nil,
        drawerSpaceContentViewBlock: ((FXDrawerView) -> UIView)? = nil
    )-> FXDrawerView {
        let view = FXDrawerView()
        view.spaceContentTrailingOffset = spaceContentTrailingOffset
        view.drawerContentLeadingOffset = drawerContentLeadingOffset
        view.drawerContentTrailingOffset = drawerContentTrailingOffset
        view.addGestureRecognizer(view.pan)
        view.drawerType = drawerType
        view.drawerContentViewBlock = drawerContentViewBlock
        view.drawerSpaceContentViewBlock = drawerSpaceContentViewBlock
        view.reload()
        return view
    }
    
    // MARK: - ***************** 弹窗
    /// 创建并显示一个弹窗
    class public func createPop(
        drawerType: DrawerType = .bottom,
        toView: UIView? = FxGetKeyWindow(),
        spaceContentTrailingOffset: Double = 0.0,
        drawerContentLeadingOffset: Double = 0.0,
        drawerContentTrailingOffset: Double = 0.0,
        drawerContentViewBlock:  ((FXDrawerView) -> UIView)? = nil,
        drawerContentViewSpaceContentViewTapBlock: ((FXDrawerView) -> Void)? = nil
    )-> FXDrawerView? {
        if let toView = toView {
            let view = FXDrawerView()
            view.spaceContentTrailingOffset = spaceContentTrailingOffset
            view.drawerContentLeadingOffset = drawerContentLeadingOffset
            view.drawerContentTrailingOffset = drawerContentTrailingOffset
            view.drawerType = drawerType
            view.drawerContentViewBlock = drawerContentViewBlock
            view.drawerContentViewSpaceContentViewTapBlock = drawerContentViewSpaceContentViewTapBlock
            view.spaceContentView.addGestureRecognizer(view.tap)
            view.spaceContentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            view.translatesAutoresizingMaskIntoConstraints = false
            toView.addSubview(view)
            NSLayoutConstraint.activate([
                view.leftAnchor.constraint(equalTo: toView.leftAnchor),
                view.topAnchor.constraint(equalTo: toView.topAnchor),
                view.rightAnchor.constraint(equalTo: toView.rightAnchor),
                view.bottomAnchor.constraint(equalTo: toView.bottomAnchor)
            ])
            view.reload()
            view.spaceContentView.alpha = 0
            toView.setNeedsLayout()
            toView.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .layoutSubviews]) {
                view.openDrawerView()
                view.spaceContentView.alpha = 1
            } completion: { finish in
                if finish {
                }
            }
            return view
        }
        return nil
    }
    
    /// 关闭并隐藏弹窗
    public func hiddenPopView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .layoutSubviews]) {
            self.closeDrawerView()
            self.spaceContentView.alpha = 0
        } completion: { finish in
            if finish {
                self.removeFromSuperview()
            }
        }
    }
    // MARK: - ***************** 特殊弹窗
    /// 创建一个弹窗
    class public func createPrePop(
        drawerType: DrawerType = .bottom,
        spaceContentTrailingOffset: Double = 0.0,
        drawerContentLeadingOffset: Double = 0.0,
        drawerContentTrailingOffset: Double = 0.0,
        drawerContentViewBlock:  ((FXDrawerView) -> UIView)? = nil,
        drawerContentViewSpaceContentViewTapBlock: ((FXDrawerView) -> Void)? = nil
    )-> FXDrawerView {
        let view = FXDrawerView()
        view.spaceContentTrailingOffset = spaceContentTrailingOffset
        view.drawerContentLeadingOffset = drawerContentLeadingOffset
        view.drawerContentTrailingOffset = drawerContentTrailingOffset
        view.drawerType = drawerType
        view.drawerContentViewBlock = drawerContentViewBlock
        view.drawerContentViewSpaceContentViewTapBlock = drawerContentViewSpaceContentViewTapBlock
        view.spaceContentView.addGestureRecognizer(view.tap)
        view.pierceThrough = true
        view.spaceContentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        view.spaceContentView.alpha = 0
        view.reload()
        return view
    }
    
    /// 显示弹窗
    public func showPrePopView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .layoutSubviews]) {
            self.openDrawerView()
            self.spaceContentView.alpha = 1
        } completion: { finish in
            if finish {
                self.pierceThrough = false
            }
        }
    }
    
    /// 关闭弹窗
    public func hiddenPrePopView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .layoutSubviews]) {
            self.closeDrawerView()
            self.spaceContentView.alpha = 0
        } completion: { finish in
            if finish {
                self.pierceThrough = true
            }
        }
    }
    
    // MARK: - ***************** 吐司
    /// 创建一个吐司
    class public func showToast(message: String, drawerType: DrawerType = .center) {
        if let toView = FxGetKeyWindow() {
            let toastDrawerView = FXDrawerView()
            toastDrawerView.drawerType = drawerType
            toastDrawerView.drawerContentViewBlock = { drawerView in
                let view = FXToastView()
                view.magLab.text = message
                return view
            }
            toastDrawerView.translatesAutoresizingMaskIntoConstraints = false
            toView.addSubview(toastDrawerView)
            NSLayoutConstraint.activate([
                toastDrawerView.leftAnchor.constraint(equalTo: toView.leftAnchor),
                toastDrawerView.topAnchor.constraint(equalTo: toView.topAnchor),
                toastDrawerView.rightAnchor.constraint(equalTo: toView.rightAnchor),
                toastDrawerView.bottomAnchor.constraint(equalTo: toView.bottomAnchor)
            ])
            toastDrawerView.reload()
            toView.setNeedsLayout()
            toView.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .layoutSubviews]) {
                toastDrawerView.openDrawerView()
            } completion: { finish in
                if finish {

                }
            }
            
            let duration: TimeInterval = 2
            toastDrawerView.timer = Timer(timeInterval: duration, target: toastDrawerView, selector: #selector(toastTimerDidFinish(_:)), userInfo: toastDrawerView, repeats: false)
            RunLoop.main.add(toastDrawerView.timer!, forMode: RunLoopMode.commonModes)
        }
        
    }
    
    @objc func toastTimerDidFinish(_ timer: Timer) {
//        guard let toast = timer.userInfo as? FXDrawerView else { return }
//        toast.hiddenDrawerView()
        timer.invalidate()
        self.timer = nil
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .layoutSubviews]) {
            self.closeDrawerView()
        } completion: { finish in
            if finish {
                self.removeFromSuperview()
            }
        }
    }
}
