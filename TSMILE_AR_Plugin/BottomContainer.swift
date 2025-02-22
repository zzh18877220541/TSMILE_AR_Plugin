//
//  BottomContainer.swift
//  TSMILE_AR_Plugin
//
//  Created by 周子皓 on 2024/11/17.
//

import SwiftUI

struct BottomContainer: View {
    @ObservedObject var viewModel: ARViewModel
    @State private var isBottomBar: Bool = true // 默认显示 BottomBar
    var switchToARplane: () -> Void
    var switchToARvideo: () -> Void
    var inVideo: Bool

    var body: some View {
        if isBottomBar {
            BottomBar(viewModel: viewModel, switchToBottomList: {
                withAnimation(.easeInOut) { // 切换动画
                    isBottomBar = false
                }
            }, inVideo: inVideo)
        } else {
            BottomList(switchToBottomBar: {
                withAnimation(.easeInOut) { // 切换动画
                    isBottomBar = true
                }
            }, switchToARplane: {switchToARplane()},
            switchToARvideo: {switchToARvideo()})
                .transition(.move(edge: .bottom)) // 添加切换动画
        }
    }
}
