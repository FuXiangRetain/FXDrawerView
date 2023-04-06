//
//  ViewController.swift
//  FXDrawerView
//
//  Created by fuxiangretain@163.com on 04/06/2023.
//  Copyright (c) 2023 fuxiangretain@163.com. All rights reserved.
//

import UIKit
import FXDrawerView

class ViewController: UIViewController {
    
    
    lazy var popStackView: UIStackView = {
        
        let btnTitles = ["左侧弹窗", "右侧弹窗", "顶部弹窗", "底部弹窗", "中心弹窗"]
        var btns: [UIButton] = []
        for (index, title) in btnTitles.enumerated() {
            let btn = UIButton()
            btn.tag = index
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.black, for: .normal)
            btn.addTarget(self, action: #selector(popBtnClick), for: .touchUpInside)
            btns.append(btn)
        }
        let stackView = UIStackView(arrangedSubviews: btns)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        btns.forEach { btn in
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        view.addSubview(stackView)
        return stackView
    }()
    
    @objc func popBtnClick(sender: UIButton) {
        _ = FXDrawerView.createPop(
            drawerType: FXDrawerView.DrawerType(rawValue: sender.tag)!,
            toView: view,
            spaceContentTrailingOffset: -16,
            drawerContentLeadingOffset: 16,
            drawerContentTrailingOffset: -16,
            drawerContentViewBlock: { drawerView in
                let contentView = PopContentView {
                    drawerView.hiddenPopView()
                }
                drawerView.pierceThrough = false
                drawerView.disablePierceThroughViews.append(contentView)
                return contentView
            }, drawerContentViewSpaceContentViewTapBlock: { drawerView in
                drawerView.hiddenPopView()
            })
    }
    
    lazy var toastStackView: UIStackView = {
        
        let btnTitles = ["左侧吐司", "右侧吐司", "顶部吐司", "底部吐司", "中心吐司"]
        var btns: [UIButton] = []
        for (index, title) in btnTitles.enumerated() {
            let btn = UIButton()
            btn.tag = index
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.black, for: .normal)
            btn.addTarget(self, action: #selector(toastBtnClick), for: .touchUpInside)
            btns.append(btn)
        }
        let stackView = UIStackView(arrangedSubviews: btns)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        btns.forEach { btn in
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        view.addSubview(stackView)
        return stackView
    }()
    
    @objc func toastBtnClick(_ sender: UIButton) {
        FXDrawerView.showToast(
            message: sender.currentTitle!,
            drawerType: FXDrawerView.DrawerType(rawValue: sender.tag)!)
    }
    
    lazy var drawerView: FXDrawerView = {
       let drawerView = FXDrawerView.createPrePop(
        spaceContentTrailingOffset: 70,
        drawerContentLeadingOffset: 16,
        drawerContentTrailingOffset: -16,
        drawerContentViewBlock: { drawerView in
            let contentView = PrePopContentView(openBlock: {
                drawerView.showPrePopView()
            }, closeBlock: {
                drawerView.hiddenPrePopView()
            })
            drawerView.disablePierceThroughViews = [contentView]
            return contentView
        }, drawerContentViewSpaceContentViewTapBlock: { drawerView in
            drawerView.hiddenPrePopView()
        })
        drawerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(drawerView)
        return drawerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        
        let leftDrawer = FXDrawerView.createDrawer(drawerType: .left) { drawerView in
            let lab = UILabel()
            lab.backgroundColor = .red
            lab.text = "结果"
            return lab
        } drawerSpaceContentViewBlock: { drawerView in
            let lab = UILabel()
            lab.text = "向右拖拽"
            return lab
        }
        leftDrawer.backgroundColor = .yellow
        leftDrawer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftDrawer)
        
        let rightDrawer = FXDrawerView.createDrawer(drawerType: .right) { drawerView in
            let lab = UILabel()
            lab.backgroundColor = .red
            lab.text = "结果"
            return lab
        } drawerSpaceContentViewBlock: { drawerView in
            let lab = UILabel()
            lab.text = "向左拖拽"
            return lab
        }
        rightDrawer.backgroundColor = .yellow
        rightDrawer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rightDrawer)

        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            popStackView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            popStackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            
            toastStackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            toastStackView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            
            popStackView.rightAnchor.constraint(equalTo: toastStackView.leftAnchor),
            toastStackView.widthAnchor.constraint(equalTo: popStackView.widthAnchor),
            
            leftDrawer.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 16),
            leftDrawer.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -16),
            leftDrawer.heightAnchor.constraint(equalToConstant: 44),
            leftDrawer.topAnchor.constraint(equalTo: toastStackView.bottomAnchor, constant: 16),
            
            rightDrawer.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 16),
            rightDrawer.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -16),
            rightDrawer.heightAnchor.constraint(equalToConstant: 44),
            rightDrawer.topAnchor.constraint(equalTo: leftDrawer.bottomAnchor, constant: 16),
            
            drawerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            drawerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            drawerView.topAnchor.constraint(equalTo: view.topAnchor),
            drawerView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}

class PrePopContentView: UIView {
    var openBlock: (()->Void)?
    var closeBlock: (()->Void)?
    init(openBlock:  @escaping ()->Void, closeBlock: @escaping ()->Void) {
        super.init(frame: .zero)
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.closeBlock = closeBlock
        self.openBlock = openBlock
        backgroundColor = .yellow
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        let msgLab = UILabel()
        msgLab.text = "自定义弹窗"
        msgLab.translatesAutoresizingMaskIntoConstraints = false
        msgLab.textAlignment = .center
        contentView.addSubview(msgLab)
        
        let openBtn = UIButton()
        openBtn.setTitle("展开", for: .normal)
        openBtn.translatesAutoresizingMaskIntoConstraints = false
        openBtn.addTarget(self, action: #selector(openBtnClick), for: .touchUpInside)
        contentView.addSubview(openBtn)
        openBtn.backgroundColor = .blue
        
        let closeBtn = UIButton()
        closeBtn.setTitle("关闭", for: .normal)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        
        closeBtn.backgroundColor = .blue
        contentView.addSubview(closeBtn)
        
        
        let safeArea = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(greaterThanOrEqualTo: safeArea.leftAnchor, constant: 16),
            contentView.topAnchor.constraint(greaterThanOrEqualTo: safeArea.topAnchor, constant: 16),
            contentView.rightAnchor.constraint(lessThanOrEqualTo: safeArea.rightAnchor, constant: -16),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor, constant: -16),
            contentView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            
            msgLab.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor),
            msgLab.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor),
            msgLab.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            openBtn.topAnchor.constraint(equalTo: msgLab.bottomAnchor, constant: 10),
            openBtn.centerXAnchor.constraint(equalTo: msgLab.centerXAnchor),
            openBtn.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor),
            openBtn.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor),

            
            
            closeBtn.topAnchor.constraint(equalTo: openBtn.bottomAnchor, constant: 10),
            closeBtn.centerXAnchor.constraint(equalTo: msgLab.centerXAnchor),
            closeBtn.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor),
            closeBtn.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor),
            closeBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func closeBtnClick(){
        closeBlock?()
    }
    @objc private func openBtnClick(){
        openBlock?()
    }
}


class PopContentView: UIView {
    
    var closeBlock: (()->Void)?
    init(closeBlock: @escaping ()->Void) {
        super.init(frame: .zero)
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.closeBlock = closeBlock
        backgroundColor = .yellow
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        let msgLab = UILabel()
        msgLab.text = "自定义弹窗"
        msgLab.translatesAutoresizingMaskIntoConstraints = false
        msgLab.textAlignment = .center
        contentView.addSubview(msgLab)
        
        let closeBtn = UIButton()
        closeBtn.setTitle("关闭", for: .normal)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        
        closeBtn.backgroundColor = .blue
        contentView.addSubview(closeBtn)
        
        
        let safeArea = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(greaterThanOrEqualTo: safeArea.leftAnchor, constant: 16),
            contentView.topAnchor.constraint(greaterThanOrEqualTo: safeArea.topAnchor, constant: 16),
            contentView.rightAnchor.constraint(lessThanOrEqualTo: safeArea.rightAnchor, constant: -16),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor, constant: -16),
            contentView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            
            msgLab.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor),
            msgLab.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor),
            msgLab.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            closeBtn.topAnchor.constraint(equalTo: msgLab.bottomAnchor, constant: 10),
            closeBtn.centerXAnchor.constraint(equalTo: msgLab.centerXAnchor),
            closeBtn.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor),
            closeBtn.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor),
            closeBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func closeBtnClick(){
        closeBlock?()
    }
}
