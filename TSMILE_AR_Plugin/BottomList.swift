//
//  ButtomList.swift
//  TSMILE_AR_Plugin
//
//  Created by 周子皓 on 2024/11/17.
//

import SwiftUI

struct BottomList: View {
    var switchToBottomBar: () -> Void // 切换回 BottomBar 的闭包
    var switchToARplane: () -> Void
    var switchToARvideo: () -> Void
    
    let offset = 60.0
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 60)
                    .fill(Color.white.opacity(0.5))
                    .frame(height: 195)
                    .offset(y: offset)
                HStack {
                    Button(action: {
                        switchToBottomBar()
                    }, label: {
                        Image("return")
                    })
                    .offset(CGSize(width: 25.0, height: offset - 62.0))
                    Spacer()
                    Button(action: {switchToARplane()}, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 104, height: 99)
                            .foregroundColor(Color.white)
                            .overlay(
                                RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)).stroke(Color(hex: "#36E1DC"), lineWidth: 3)
                            )
                        
                            ZStack {
                                Image("toothStruct")
                                    .offset(CGSize(width: 2.0, height: -5.0))
                                Text("牙齿结构")
                                    .fontWeight(.black)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#6A6E74"))
                                    .offset(CGSize(width: 0, height: 31))
                            }
                            
                        }
                    })
                    .offset(CGSize(width: 5.0, height: offset - 20.0))
                    
                    Spacer()
                    
                    Button(action: {switchToARvideo()}, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 104, height: 99)
                            .foregroundColor(Color.white)
                            .overlay(
                                RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)).stroke(Color(hex: "#36E1DC"), lineWidth: 3)
                        )
                        
                            ZStack {
                                Image("toothDecay")
                                    .offset(CGSize(width: 0.0, height: -10))
                                Text("蛀牙形成过程")
                                    .fontWeight(.black)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#6A6E74"))
                                    .offset(CGSize(width: 0, height: 31))
                            }
                        }
                        
                    })
                    .offset(CGSize(width: -5, height: offset - 20.0))
                    
                    Spacer()
                }
            }
        }
    }
}

