//
//  ARContainerViewController.swift
//  TSMILE_AR_Plugin
//
//  Created by 周子皓 on 2024/11/17.
//

import UIKit
import SwiftUI

class ARContainerViewController: UIViewController {
    let viewModel = ARViewModel() // 共享的 ViewModel
    var currentChild: UIViewController?
    var bottomBarHostingController: UIHostingController<BottomContainer>?
    var inVideo: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // 默认显示 ARViewController_plane
        switchToARPlane(viewModel: viewModel)
    }

    /// 切换到 ARViewController_plane
    func switchToARPlane(viewModel: ARViewModel) {
        inVideo = false
        let planeVC = ARViewController_plane(viewModel: viewModel)
        switchChild(to: planeVC)
    }

    /// 切换到 ARViewController_video
    func switchToARVideo() {
        inVideo = true
        let videoVC = ARViewController_video(viewModel: viewModel)
        switchChild(to: videoVC)
    }

    /// 切换子控制器，并重新添加底栏
    private func switchChild(to newChild: UIViewController) {
        // 移除当前子控制器
        if let currentChild = currentChild {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
        }

        // 添加新子控制器
        addChild(newChild)
        view.addSubview(newChild.view)
        newChild.view.frame = view.bounds
        newChild.didMove(toParent: self)

        currentChild = newChild

        // 确保底栏在子视图之上
        addBottomContainer()
    }

    /// 添加底栏视图
    private func addBottomContainer() {
        // 移除旧的底栏
        if let hostingController = bottomBarHostingController {
            hostingController.willMove(toParent: nil)
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
        }

        // 创建新的底栏
        let bottomBarView = BottomContainer(
            viewModel: viewModel,
            switchToARplane: { [weak self] in
                self?.switchToARPlane(viewModel: self?.viewModel ?? ARViewModel())
            },
            switchToARvideo: { [weak self] in
                self?.switchToARVideo()
            },
            inVideo: inVideo
        )

        let hostingController = UIHostingController(rootView: bottomBarView)
        hostingController.view.backgroundColor = UIColor.clear

        // 添加底栏
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        // 设置底栏布局
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.heightAnchor.constraint(equalToConstant: 300) // 底栏高度
        ])

        // 更新引用
        bottomBarHostingController = hostingController
    }
}
