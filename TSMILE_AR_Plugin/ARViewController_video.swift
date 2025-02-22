//
//  ARViewController_plane.swift
//  TSMILE_AR_Plugin
//
//  Created by 周子皓 on 2024/10/9.
//

import ARKit
import UIKit
import RealityKit
import SwiftUI

class ARViewController_video: UIViewController, ARSCNViewDelegate {
    
    let arView = ARSCNView()
    
    @ObservedObject var viewModel: ARViewModel
    
    var overlayButton: UIButton!
    
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
        
        viewModel.modelNode_video = createModel()
        
        if let modelNode = viewModel.modelNode_video {
            placeModel(model: modelNode)
        }
        
        viewModel.modelNode_video?.isPaused = true
        
        // 设置手势
        installGestures(on: viewModel.modelNode_video!)
        
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
        let delay = 1.0 / 60.0 * 500 // 100帧，假设60 FPS
        
        // 停止按钮动画并隐藏
        overlayButton.layer.removeAllAnimations()
        overlayButton.isHidden = true
        overlayButton.alpha = 0
        overlayButton.isEnabled = false
        
        // 恢复模型动画
        self.viewModel.modelNode_video!.isPaused = false
        
        // 设置延迟暂停模型动画
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.viewModel.modelNode_video!.isPaused = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 暂停 ARSession
        arView.session.pause()
    }
    
    func createModel() -> SCNNode {
        // 加载.scn文件
        let scene = SCNScene(named: "video_final.scn")
        // 获取场景的根节点
        let modelNode = scene?.rootNode.childNode(withName: "Geom", recursively: true)
        return modelNode!
    }
    
    func placeModel(model: SCNNode) {
        // 创建锚点
        model.position = SCNVector3(0, -1.5, -7)
        
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
    }
    
    @objc func handleScaleGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let modelNode = viewModel.modelNode_video else { return }
        
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
        
        viewModel.modelNode_video?.eulerAngles.y += rotationAngle
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
        }
    }
    
    // 更新图片位置
    @objc func updateOverlayPosition() {
        guard let modelNode = viewModel.modelNode_video else { return }
        
        // 获取模型的包围盒并计算中心点
        let min = modelNode.boundingBox.min
        let max = modelNode.boundingBox.max
        let center = SCNVector3(
            (min.x + max.x) / 2,
            (min.y + max.y) / 3 * 2,
            (min.z + max.z) / 2
        )
        
        // 将中心点转换为世界坐标系
        let worldCenter = modelNode.convertPosition(center, to: nil)
        
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


