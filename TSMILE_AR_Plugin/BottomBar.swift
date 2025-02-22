//
//  BottomTools.swift
//  TSMILE_AR_Plugin
//
//  Created by 周子皓 on 2024/11/17.
//

import SwiftUI

struct BottomBar: View {
    @ObservedObject var viewModel: ARViewModel // 从外部传入
    var switchToBottomList: () -> Void // 切换到 BottomList 的闭包
    var inVideo: Bool
    
    func playModelAnimations(inVideo: Bool) {
        print("click button")
        print(inVideo)
        if inVideo == false {
            if viewModel.modelNode_plane!.isPaused != false {
                let delay = 1.0 / 60.0 * 200 // 100帧，假设60 FPS
                
                // 恢复模型动画
                viewModel.modelNode_plane!.isPaused = false
                
                // 设置延迟暂停模型动画
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.viewModel.modelNode_plane!.isPaused = true
                }
            }
        } else {
            if viewModel.modelNode_video!.isPaused != false {
                let delay = 1.0 / 60.0 * 500 // 100帧，假设60 FPS
                
                // 恢复模型动画
                self.viewModel.modelNode_video!.isPaused = false
                
                // 设置延迟暂停模型动画
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.viewModel.modelNode_video!.isPaused = true
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    switchToBottomList()
                }) {
                    Image("list")
                }
                Spacer()
                Button(action: {
                    print("Button 2 tapped")
                }) {
                    ZStack {
                        RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                            .fill(Color.white)
                        .frame(width: 132, height: 67)
                        HStack {
                            Image("home")
                            Text("返回")
                                .fontWeight(.black)
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex:"#6A6E74"))
                                .frame(height: 29)
                                .offset(x: -12, y: 3)
                        }
                        
                    }
                        
                }
                .offset(CGSize(width: 16, height: -1))
                
                Spacer()
                
                Button(action: {
                    playModelAnimations(inVideo: inVideo)
                }) {
                    ZStack {
                        Image("reset")
                            .frame(width: 50, height: 64)
                            .offset(CGSize(width: 0, height: 7.0))
                        Image("reset_wrapper")
                            .frame(width: 66, height: 67)
                    }
                }
                .offset(CGSize(width: 16, height: -1))
                Spacer()
            }
            
        }
    }
}


