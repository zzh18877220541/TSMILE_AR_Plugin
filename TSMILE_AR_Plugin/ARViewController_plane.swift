//
//  ARViewController_plane.swift
//  TSMILE_AR_Plugin
//
//  Created by 周子皓 on 2024/10/9.
//

import ARKit
import UIKit
import SceneKit
import SwiftUI

class ARViewController_plane: UIViewController, ARSCNViewDelegate {
    
    let arView = ARSCNView()
    
    @ObservedObject var viewModel: ARViewModel
        
    var overlayButton: UIButton!
    
    var overlayScreenButton: UIButton?
    
    var isPopupAllowed = false
    
    var popOver: PopOver?
    
    var targetPoint: CGPoint = .zero
    
    var xRatio: Float = 0.0
    
    var yRatio: Float = 0.0
    
    init(viewModel: ARViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view = arView
        
        // 配置 ARSCNView
        arView.scene = SCNScene()
        arView.autoenablesDefaultLighting = true
        
        viewModel.modelNode_plane = createModel()
        placeModel(model: viewModel.modelNode_plane!)
        
        viewModel.modelNode_plane?.isPaused = true
        
        if let modelNode = viewModel.modelNode_plane {
            arView.scene.rootNode.addChildNode(modelNode)
            installGestures(on: modelNode)
        }
        
        // 配置 AR 会话
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // 运行会话
        arView.session.run(configuration)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupOverlayImage()
        animateOverlayImage()
        arView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 暂停 ARSession
        arView.session.pause()
    }
    
    func animateOverlayImage() {
        overlayButton.imageView?.transform = CGAffineTransform(scaleX: 3.3, y: 3.3)
        
        // 执行动画
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       options: [.autoreverse, .repeat], // 反向和循环
                       animations: {
            // 图片放大
            self.overlayButton.imageView?.transform = CGAffineTransform(scaleX: 6.0, y: 6.0)
        }, completion: nil)
    }

    
    @objc func playModelAnimations(_ sender: UIButton) {
        print("click button")
        isPopupAllowed = true
        let delay = 1.0 / 60.0 * 200 // 100帧，假设60 FPS
        
        // 停止按钮动画并隐藏
        overlayButton.layer.removeAllAnimations()
        overlayButton.isHidden = true
        overlayButton.alpha = 0
        overlayButton.isEnabled = false
        
        // 恢复模型动画
        viewModel.modelNode_plane!.isPaused = false
        
        // 设置延迟暂停模型动画
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.viewModel.modelNode_plane!.isPaused = true
        }
    }
    
    func createModel() -> SCNNode {
        for family in UIFont.familyNames {
            print("Font family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("Font name: \(name)")
            }
        }

        // 加载.scn文件
        let scene = SCNScene(named: "Explode_named.scn")
        // 获取场景的根节点
        viewModel.modelNode_plane = scene?.rootNode.childNode(withName: "Geom", recursively: true)
        // 打印结构
        let toothModelNode = viewModel.modelNode_plane?.childNode(withName:
        "Structure", recursively: true)
        for childNode in toothModelNode?.childNodes ?? [] {
            // 检查每个部分的名称
            if let partName = childNode.name {
                print("Part name: \(partName)")  // 输出部分名称用于调试
            }
            // 添加物理体用于碰撞检测
            childNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        }
        return viewModel.modelNode_plane!
    }
    
    func placeModel(model: SCNNode) {
        // 创建锚点
        model.position = SCNVector3(0, -0.45, -1)
        
        // 将模型添加到场景
        arView.scene.rootNode.addChildNode(model)
    }
    
    func installGestures(on object: SCNNode) {
        // 缩放
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleScaleGesture(_:)))
        arView.addGestureRecognizer(scaleGesture)
        // 旋转
        let rotationGesture = UIPanGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        arView.addGestureRecognizer(rotationGesture)
        // 点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        guard let modelNode = viewModel.modelNode_plane else { return }
        
        let location = gestureRecognize.location(in: arView)
        
        // 进行 hitTest，获取被点击的节点
        let hitResults = arView.hitTest(location, options: nil)
        
        if let result = hitResults.first {
            // 获取点击的节点
            let tappedNode = result.node
            
            if let partName = tappedNode.name {
                print("Tapped part: \(partName)")  // 输出点击的部位名称
                // 显示弹窗
                showInfoPopup(partName: partName, targetPoint: location, modelTitle: partName)
            }
        }
    }

    // 显示信息弹窗
    func showInfoPopup(partName: String, targetPoint: CGPoint, modelTitle: String) {
        // 获取屏幕的宽度和高度
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        
        // 获取安全区域的边缘插入（顶部、底部、左侧、右侧）
        let safeAreaTop = view.safeAreaInsets.top
        let safeAreaBottom = view.safeAreaInsets.bottom
        let safeAreaLeft = view.safeAreaInsets.left
        let safeAreaRight = view.safeAreaInsets.right
        
        // 计算四个边缘的坐标
        let topEdgeY = safeAreaTop
        let leftEdgeX = safeAreaLeft
        let rightEdgeX = screenWidth - safeAreaRight
        let bottomEdgeY = screenHeight - safeAreaBottom
        
        var title: String
        var content: String
        
        switch modelTitle {
        case "Crown":
            title = "牙冠"
        case "Alveolar_Bone":
            title = "牙槽骨"
        case "Cervix":
            title = "牙颈"
        case "Dentine":
            title = "牙本质"
        case "Gum":
            title = "牙龈"
        case "Pulp_Chamber":
            title = "髓腔"
        case "Root":
            title = "牙根"
        case "Root_Canal1":
            title = "根管"
        case "Root_Canal2":
            title = "根管"
        default:
            title = ""
        }
        
        switch title {
        case "牙冠":
            content = "牙齿暴露在口腔中的部分，主要由牙釉质覆盖，具有咀嚼功能，并保护内部牙体组织。"
        case "牙龈":
            content = "支撑和保护牙齿，具有防御功能，覆盖于牙槽突边缘区及牙颈间。"
        case "牙颈":
            content = "牙冠与牙根之间的部分，被牙龈包绕，连接釉质和牙骨质。"
        case "牙根":
            content = "牙齿埋在牙龈里的部分，有牙骨质覆盖，起支撑牙体功效。"
        case "牙槽骨":
            content = "上颌骨下缘、下颌骨上缘镶嵌牙根的部位，由骨皮质等构成。"
        case "牙釉质":
            content = "覆盖在牙冠表面，具有抗剪切能力，使牙齿不易劈裂。"
        case "牙本质":
            content = "位于釉质内层，有渗透性，可以形成修复性牙本质，保护牙髓。"
        case "髓腔":
            content = "位于牙体内部，容纳牙髓。"
        case "根管":
            content = "在牙根的底部，连接髓腔和外界，内有牙髓、血管等。"
        default:
            content = ""
        }
        
        guard let modelNode = viewModel.modelNode_plane else { return }
        
        let min = modelNode.boundingBox.min
        let max = modelNode.boundingBox.max
        
        xRatio = (min.x + max.x) / Float(targetPoint.x)
        yRatio = (min.y + max.y) / Float(targetPoint.y)

        
        print(targetPoint)
        popOver = PopOver(targetPoint: targetPoint, topEdgeY: topEdgeY, leftEdgeX: leftEdgeX, rightEdgeX: rightEdgeX, bottomEdgeY: bottomEdgeY, title: title, content: content)
        if isPopupAllowed == true {
            if let popOver = popOver {
                arView.addSubview(popOver)
            }
            isPopupAllowed = false
            print("add popover is not allowed")
        }
        // 添加遮罩按钮
        overlayScreenButton = UIButton(frame: arView.bounds)
        overlayScreenButton?.backgroundColor = UIColor(white: 0, alpha: 0.01) // 透明按钮
        overlayScreenButton?.addTarget(self, action: #selector(hidePopup), for: .touchUpInside)
        if let overlayButton = overlayScreenButton {
            arView.addSubview(overlayButton)
            print("add overlayScreenButton")
        }
    }
    
    // 隐藏弹窗和遮罩
    @objc func hidePopup() {
        popOver?.removeFromSuperview()
        popOver = nil
        overlayScreenButton?.removeFromSuperview()
        overlayScreenButton = nil
        isPopupAllowed = true // 禁止弹窗再次显示，直到重新启用
        print("add popover is allowed")
    }
    
    @objc func handleScaleGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let modelNode = viewModel.modelNode_plane else { return }
        
        // 通过手势的缩放比例来设置新的缩放值
        let scaleFactor = Float(gesture.scale)
        
        // 设置缩放比例的上下限，避免模型缩放过大或过小
        let currentScale = modelNode.scale
        let newScale = SCNVector3(
            currentScale.x * scaleFactor,
            currentScale.y * scaleFactor,
            currentScale.z * scaleFactor
        )
        
        // 应用缩放
        modelNode.scale = newScale
        
        // 重置手势缩放比例，以便连续缩放
        gesture.scale = 1.0
    }

    
    @objc func handleRotationGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: arView)
        // 控制旋转速度
        let rotationAngle = Float(translation.x) * 0.001
        
        viewModel.modelNode_plane?.eulerAngles.y += rotationAngle
    }
    
    // 设置覆盖图片
    func setupOverlayImage() {
        print("init point")
        
        // 初始化按钮并应用图片
        overlayButton = UIButton(type: .custom)
        overlayButton.setImage(UIImage(named: "ClickPoint"), for: .normal)
        
        //设置按钮外观
        overlayButton.imageView?.contentMode = .scaleAspectFit
        overlayButton.frame.size = CGSize(width: 100, height: 100) // 设置图片大小
        overlayButton.center = view.center // 初始位置
        
        // 添加点击事件
        overlayButton.addTarget(self, action: #selector(playModelAnimations(_:)), for: .touchUpInside)
        view.addSubview(overlayButton)
        view.bringSubviewToFront(overlayButton)  // 确保按钮在最前层
    }
    
    //实现 ARSCNViewDelegate 方法，每帧更新图片位置
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateOverlayPosition()
            //self.updatePopOver(xRatio: self.xRatio, yRatio: self.yRatio, targetPoint: self.targetPoint)
        }
    }
    
    @objc func updatePopOver(xRatio: Float, yRatio: Float, targetPoint: CGPoint) {
        guard let modelNode = viewModel.modelNode_plane else { return }
        
        // 获取模型的包围盒并计算中心点
        let min = modelNode.boundingBox.min
        let max = modelNode.boundingBox.max
        let targetPoint = SCNVector3(
            (min.x + max.x) / xRatio,
            (min.y + max.y) / yRatio,
            (min.z + max.z) / 2
        )
        
        // 将中心点转换为世界坐标系
        let worldTarget = viewModel.modelNode_plane!.convertPosition(targetPoint, to: nil)
        
        // 将世界坐标转换为屏幕坐标
        let projectedPoint = arView.projectPoint(worldTarget)
        //print("Projected Point:", projectedPoint)
        
        // 如果坐标在屏幕内，则更新图片位置
        if projectedPoint.z > 0 {
            let screenPoint = CGPoint(x: CGFloat(projectedPoint.x), y: CGFloat(projectedPoint.y))
            popOver?.isHidden = false
            if let popOver = popOver {
                var newFrame = popOver.frame
                let deltaX = screenPoint.x - CGFloat(targetPoint.x)
                let deltaY = screenPoint.y - CGFloat(targetPoint.y)
                newFrame.origin.x += deltaX
                newFrame.origin.y += deltaY
                popOver.frame = newFrame
            }

            //print("hide point")
        } else {
            popOver?.isHidden = true
            //print("show point")
        }
    }
    
    // 更新图片位置
    @objc func updateOverlayPosition() {
        guard let modelNode = viewModel.modelNode_plane else { return }
        
        // 获取模型的包围盒并计算中心点
        let min = modelNode.boundingBox.min
        let max = modelNode.boundingBox.max
        let center = SCNVector3(
            (min.x + max.x) / 2,
            (min.y + max.y) / 3 * 2,
            (min.z + max.z) / 2
        )
        
        // 将中心点转换为世界坐标系
        let worldCenter = viewModel.modelNode_plane!.convertPosition(center, to: nil)
        
        // 将世界坐标转换为屏幕坐标
        let projectedPoint = arView.projectPoint(worldCenter)
        //print("Projected Point:", projectedPoint)
        
        // 如果坐标在屏幕内，则更新图片位置
        if projectedPoint.z > 0 {
            let screenPoint = CGPoint(x: CGFloat(projectedPoint.x), y: CGFloat(projectedPoint.y))
            overlayButton.center = screenPoint
            overlayButton.isHidden = false
            //print("hide point")
        } else {
            overlayButton.isHidden = true
            //print("show point")
        }
    }
    
}


