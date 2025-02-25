//
//  ARViewController_SceneKit.swift
//  TSMILE_AR_Plugin
//
//  Created by 周子皓 on 2024/10/28.
//

import UIKit
import SceneKit

class ARViewController_SceneKit: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建一个SceneKit视图
        let sceneView = SCNView(frame: self.view.bounds)
        self.view.addSubview(sceneView)
        
        // 加载.scn文件中的场景
        guard let scene = SCNScene(named: "爆炸图.scn") else {
            fatalError("无法加载.scn文件")
        }
        
        // 设置SceneKit视图的场景
        sceneView.scene = scene
        
        // 启用默认灯光
        sceneView.autoenablesDefaultLighting = true
        
        // 显示帧率和其他信息
        sceneView.showsStatistics = true
        
        // 允许用户控制相机
        sceneView.allowsCameraControl = true
        
        let delay = 1.0 / 60.0 * 100 // 100帧，假设60 FPS
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            scene.isPaused = true
        }
                
    }
}
