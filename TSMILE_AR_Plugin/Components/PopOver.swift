//
//  PopOver_Crown.swift
//  TSMILE_AR_Plugin
//
//  Created by 周子皓 on 2024/11/5.
//

import UIKit

class PopOver: UIView {
    
    // 初始化方法，传入可定制的内容和样式
    init(targetPoint: CGPoint,
         // 屏幕参数
         topEdgeY: CGFloat,
         leftEdgeX: CGFloat,
         rightEdgeX: CGFloat,
         bottomEdgeY: CGFloat,
         lineLength: CGFloat = 200,
         circleRadius: CGFloat = 5.0,
         cornerRadius: CGFloat = 20.0,
         title: String,
         content: String,
         titleFont: UIFont = UIFont(name: "HarmonyOS_Sans_SC_Bold", size: 25)!,
         contentFont: UIFont = UIFont(name: "HarmonyOS_Sans_SC", size: 15)!,
         titleColor: UIColor = UIColor(hex: "6A6E74"),
         contentColor: UIColor = UIColor(hex: "6A6E74"),
         lineColor: UIColor = .white,
         backgroundColor: UIColor = UIColor(white: 1.0, alpha: 0.8),
         borderColor: UIColor = .lightGray) {
        
        super.init(frame: .zero)
        
        // 设置视图大小，便于布局
        self.frame = UIScreen.main.bounds
        
        setupDialogueBox(targetPoint: targetPoint,
                         topEdgeY: topEdgeY,
                         leftEdgeX: leftEdgeX,
                         rightEdgeX: rightEdgeX,
                         bottomEdgeY: bottomEdgeY,
                         lineLength: lineLength,
                         circleRadius: circleRadius,
                         cornerRadius: cornerRadius,
                         title: title,
                         content: content,
                         titleFont: titleFont,
                         contentFont: contentFont,
                         titleColor: titleColor,
                         contentColor: contentColor,
                         lineColor: lineColor,
                         backgroundColor: backgroundColor,
                         borderColor: borderColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum popOverType {
        case Up
        case Down
        case Left
        case Right
    }
    
    private func selectType(upDistance: CGFloat, downDistance: CGFloat, leftDistance: CGFloat, rightDistance: CGFloat) -> popOverType {
        let minWidth = 200.0
        if leftDistance < minWidth / 2 {
            //debug
            print("right")
            return popOverType.Right
        } else if rightDistance < minWidth / 2 {
            //debug
            print("left")
            return popOverType.Left
        } else {
            if upDistance > downDistance {
                //debug
                print("up")
                return popOverType.Up
            } else {
                //debug
                print("down")
                return popOverType.Down
            }
        }
    }
    
    private func calculateLineTopPoint(targetPoint: CGPoint, lineLength: CGFloat, type: popOverType) -> CGPoint {
        switch type {
        case .Up:
            return CGPoint(x: targetPoint.x, y: targetPoint.y - lineLength)
        case .Down:
            return CGPoint(x: targetPoint.x, y: targetPoint.y + lineLength)
        case .Left:
            return CGPoint(x: targetPoint.x - lineLength, y: targetPoint.y)
        case .Right:
            return CGPoint(x: targetPoint.x + lineLength, y: targetPoint.y)
        }
    }
    
    private func drawLine(targetPoint: CGPoint, type: popOverType, lineColor: UIColor) -> (CAShapeLayer, CGPoint) {
        let lineLength = (type == popOverType.Down || type == popOverType.Up) ? 100.0 : 50.0
        
        let lineTopPoint = calculateLineTopPoint(targetPoint: targetPoint, lineLength: lineLength, type: type)
        
        // 绘制线条
        let path = UIBezierPath()
        path.move(to: targetPoint)
        path.addLine(to: lineTopPoint)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = 2.0
        
        return (lineLayer, lineTopPoint)
    }
    
    private func setLabel(cornerRadius: CGFloat,
                          title: String,
                          content: String,
                          titleFont: UIFont,
                          contentFont: UIFont,
                          titleColor: UIColor,
                          contentColor: UIColor,
                          backgroundColor: UIColor,
                          borderColor: UIColor,
                          FinalWidth: CGFloat,
                          lineTopPoint: CGPoint,
                          type: popOverType,
                          titlePadding: CGFloat = 8.0,
                          contentPadding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)) -> UILabel {
        
        // 创建 UILabel
        let label = PaddingLabel(padding: contentPadding) // 自定义UILabel用于内边距
        label.numberOfLines = 0 // 允许多行
        label.textAlignment = .center // 整体居中
        label.backgroundColor = backgroundColor // 设置背景颜色
        label.layer.cornerRadius = cornerRadius
        label.layer.masksToBounds = true // 确保圆角效果生效
        label.layer.borderColor = borderColor.cgColor // 设置边框颜色
        label.layer.borderWidth = 1.0 // 设置边框宽度，可根据需要调整
        label.textColor = nil
        
        // 创建富文本
        let attributedText = NSMutableAttributedString()
        
        // Title部分
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.paragraphSpacing = titlePadding // 上下padding
        titleParagraphStyle.alignment = .center
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: titleColor,
            .paragraphStyle: titleParagraphStyle,
        ]
        let titleAttributedString = NSAttributedString(string: "\(title)\n", attributes: titleAttributes)
        attributedText.append(titleAttributedString)
        
        // Content部分
        let contentParagraphStyle = NSMutableParagraphStyle()
        contentParagraphStyle.paragraphSpacing = contentPadding.top // 内容部分的上padding
        
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: contentFont,
            .foregroundColor: contentColor,
            .paragraphStyle: contentParagraphStyle
        ]
        let contentAttributedString = NSAttributedString(string: content, attributes: contentAttributes)
        attributedText.append(contentAttributedString)
        
        // 设置 UILabel 的富文本内容
        label.attributedText = attributedText
        
        // 调整 UILabel 的宽度
        label.frame.size.width = FinalWidth
        label.sizeToFit()
        label.frame.size.width = FinalWidth // 保持宽度不变
        
        // 根据类型设置 UILabel 的位置
        switch type {
        case .Up:
            label.center = CGPoint(x: lineTopPoint.x, y: lineTopPoint.y - label.frame.height / 2)
        case .Down:
            label.center = CGPoint(x: lineTopPoint.x, y: lineTopPoint.y + label.frame.height / 2)
        case .Left:
            label.center = CGPoint(x: lineTopPoint.x - label.frame.width / 2, y: lineTopPoint.y)
        case .Right:
            label.center = CGPoint(x: lineTopPoint.x + label.frame.width / 2, y: lineTopPoint.y)
        }
        
        return label
    }

    // 自定义UILabel，支持内边距
    class PaddingLabel: UILabel {
        var padding: UIEdgeInsets = .zero
        
        init(padding: UIEdgeInsets) {
            self.padding = padding
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
            // 获取文本内容的实际大小
            var textRect = super.textRect(forBounds: bounds.inset(by: padding), limitedToNumberOfLines: numberOfLines)
            
            // 根据内边距扩展 textRect 的大小
            textRect.origin.x -= padding.left
            textRect.origin.y -= padding.top
            textRect.size.width += padding.left + padding.right
            textRect.size.height += padding.top + padding.bottom
            return textRect
        }
        
        override func drawText(in rect: CGRect) {
            // 使用缩进的 rect 来绘制文本
            super.drawText(in: rect.inset(by: padding))
        }
    }

    
    private func setupDialogueBox(targetPoint: CGPoint,
                                  // 屏幕参数
                                  topEdgeY: CGFloat,
                                  leftEdgeX: CGFloat,
                                  rightEdgeX: CGFloat,
                                  bottomEdgeY: CGFloat,
                                  // 当前传入的是最长的线条距离
                                  lineLength: CGFloat,
                                  circleRadius: CGFloat,
                                  cornerRadius: CGFloat,
                                  title: String,
                                  content: String,
                                  titleFont: UIFont,
                                  contentFont: UIFont,
                                  titleColor: UIColor,
                                  contentColor: UIColor,
                                  lineColor: UIColor,
                                  backgroundColor: UIColor,
                                  borderColor: UIColor) {
        // 通过屏幕参数来选择绘制线条的类型
        var type: popOverType
        // 选择最优的
        let upDistance = targetPoint.y - topEdgeY
        let downDistance = bottomEdgeY - targetPoint.y
        let leftDistance = targetPoint.x - leftEdgeX
        let rightDistance = rightEdgeX - targetPoint.x
        
        type = selectType(upDistance: upDistance, downDistance: downDistance, leftDistance: leftDistance, rightDistance: rightDistance)
        
        let (lineLayer, lineTopPoint) = drawLine(targetPoint: targetPoint, type: type, lineColor: lineColor)
        self.layer.addSublayer(lineLayer)
        
        // 绘制端点
        print(targetPoint)
        let circlePath = UIBezierPath(arcCenter: targetPoint, radius: circleRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = lineColor.cgColor
        self.layer.addSublayer(circleLayer)
        
        var FinalWidth: CGFloat
        if type == popOverType.Down || type == popOverType.Up {
            FinalWidth = 200.0
        } else {
            FinalWidth = 100.0
        }
        
        let Label = setLabel(cornerRadius: cornerRadius, title: title, content: content, titleFont: titleFont, contentFont: contentFont, titleColor: titleColor, contentColor: contentColor, backgroundColor: backgroundColor, borderColor: borderColor, FinalWidth: FinalWidth, lineTopPoint: lineTopPoint, type: type)
        
        self.addSubview(Label)
    }
}
