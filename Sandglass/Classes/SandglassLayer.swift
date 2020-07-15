//
//  SandglassLayer.swift
//  Sandglass
//
//  Created by apple on 2020/7/13.
//

import UIKit

/// 背景框架
public class SandglassLayer: CAShapeLayer {
    // MARK: - public property
    /// 背景线条颜色
    public var bgStrokeColor: UIColor? {
        set {
            bgLayer.strokeColor = newValue?.cgColor
        }
        get {
            bgLayer.strokeColor?.uiColor
        }
    }
    
    /// 背景架子的线宽
    public var bgLineWidth: CGFloat {
        set {
            bgLayer.lineWidth = newValue
            bgLayer0.lineWidth = newValue
        }
        get {
            bgLayer.lineWidth
        }
    }
    
    /// 沙子颜色
    public var sandColor: UIColor = UIColor.systemRed {
        didSet {
            topSandLayer.fillColor = sandColor.cgColor
            bottomSandLayer.fillColor = sandColor.cgColor
            emitterLayer.emitterCells?.first?.contents = UIImage.roundColor(sandColor, wh: 1.5 * 1.5).cgImage
        }
    }
    /// 进度管理
    private var _progress: CGFloat = 0
    public var progress: CGFloat {
        set {
            if newValue == _progress {
                return
            }
            if newValue < 0 {
                _progress = 0
            } else if newValue > 1 {
                _progress = 1
            } else {
                _progress = newValue
            }
            setProgress(_progress)
        }
        get {
            _progress
        }
    }
    
    // MARK: - private property
    /// 顶部镂空图层  (确定为水平下降方式不需要镂空)
    //private lazy var shapeLayer = CAShapeLayer()
    /// 顶部沙子
    private lazy var topSandLayer: CAShapeLayer = {
        $0.fillColor = sandColor.cgColor
        $0.lineWidth = 0.0
        insertSublayer($0, at: 0)
        return $0
    }(CAShapeLayer())
    
    
    /// 底部沙子
    private lazy var bottomSandLayer: CAShapeLayer = {
         $0.fillColor = sandColor.cgColor
        insertSublayer($0, at: 0)
        return $0
    }(CAShapeLayer())
    
    /// 小孔
    private lazy var holeLayer: CALayer = {
        $0.backgroundColor = UIColor.white.cgColor
        addSublayer($0)
        return $0
    }(CALayer())
    
    /// 灰色透明背景图层
    private(set) lazy var bgLayer: CAShapeLayer = {
        //$0.strokeColor = bgStokeColor.cgColor
        addSublayer($0)
        $0.lineJoin = "round"
        $0.lineCap = "round"
        $0.fillColor = UIColor.clear.cgColor
        return $0
    }(CAShapeLayer())
    /// 白底图层 在 bgLayer 之下 灰色透明背景图层 变得没有透明
    private(set) lazy var bgLayer0: CAShapeLayer = {
        $0.strokeColor = UIColor.white.cgColor
        addSublayer($0)
        $0.lineJoin = "round"
        $0.lineCap = "round"
        $0.fillColor = UIColor.clear.cgColor
        return $0
    }(CAShapeLayer())
    
    /// 粒子cell  一些参数设置之后会与 emitterLayer 设置的参数相乘 可以设置多个cell
    private lazy var cell: CAEmitterCell = {
        let cell = CAEmitterCell()
        cell.contents = UIImage.roundColor(sandColor, wh: 1.5 * 1.5).cgImage
        //每秒粒子产生个数的乘数因子，会和layer的birthRate相乘，然后确定每秒产生的粒子个数
        cell.birthRate = 120
        //每个粒子存活时长
        cell.lifetime = 0.25
        //粒子生命周期范围
        cell.lifetimeRange = 0.3
        //粒子透明度变化，设置为－0.4，就是每过一秒透明度就减少0.4，这样就有消失的效果,一般设置为负数。
        cell.alphaSpeed = -1
        cell.alphaRange = 0.1
        //粒子的速度
        cell.velocity = 0
        //粒子的速度范围
        cell.velocityRange = 25
        //周围发射的角度，如果为M_PI*2 就可以从360度任意位置发射
        cell.emissionRange = 0
        //粒子内容的颜色
        //    cell.color = [[UIColor whiteColor] CGColor]
        
        cell.redRange = 0.5
        cell.blueRange = 0.5
        cell.greenRange = 0.5
        
        //缩放比例
        cell.scale = 0.2
        //缩放比例范围
        cell.scaleRange = 0.02
        
        //粒子的初始发射方向
        cell.emissionLongitude = 0 //CGFloat.pi * 0.005
        cell.emissionLatitude = 0
        //Y方向的加速度
        cell.yAcceleration = 250.0
        return cell
    }()
    
    /// 沙子下落部分
    private lazy var emitterLayer: CAEmitterLayer = {
        //X方向加速度 只有下落速度不用设置
           // cell.xAcceleration = 20.0
        //发射位置
        //$0.emitterPosition = CGPoint(x: bounds.width/2.0, y: 0)
        //粒子产生系数，默认为1
        //
        //发射器的尺寸
        $0.emitterSize = CGSize(width: 0.1, height: 1)
        //发射的形状
        $0.emitterShape = kCAEmitterLayerCircle
        //发射的模式
        $0.emitterMode = kCAEmitterLayerOutline
        //渲染模式
        $0.renderMode = kCAEmitterLayerUnordered
        
        $0.zPosition = 0
        $0.emitterCells = [cell]
        $0.masksToBounds = true
        return $0
    }(CAEmitterLayer())
    
    // MARK: - override
    public override var lineWidth: CGFloat {
        didSet {
            if lineWidth == oldValue {
                return
            }
            reDrawPath()
        }
    }
    
    public override var frame: CGRect {
        didSet {
            if frame.size == oldValue.size {
                return
            }
            reDrawPath()
        }
    }
    
    /// 触发重新绘制
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        let point = CGPoint(x: bounds.midX - lineWidth * 0.25, y: bounds.midY - lineWidth)
        
        holeLayer.frame = CGRect(origin: point, size: CGSize(width: lineWidth * 0.5, height: lineWidth * 2))
        
        topSandLayer.frame = bounds
        
        bottomSandLayer.frame = bounds
        
        bgLayer.frame = bounds
        
        setProgress(progress)
    }
}

// MARK: - animator
extension SandglassLayer {
    
    public func beginAnimate() {
        emitterLayer.frame = bounds
        insertSublayer(emitterLayer, at: 0)
        addSublayer(bottomSandLayer)
        //发射位置
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY + lineWidth)
        emitterLayer.birthRate = 1
    }
    
     public func endAnimate() {
        emitterLayer.birthRate = 0
        emitterLayer.removeFromSuperlayer()
     }
}

// MARK: - draw
extension SandglassLayer {
    /// 重新绘制
    private func reDrawPath() {
        if bounds.size == .zero {
            return
        }
        
        setBGPath()
        
        setProgress(progress)
    }
    
    /// 设置背景区域
    private func setBGPath() {
        let path = UIBezierPath()
        let centerP = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let radius = (bounds.height - lineWidth) * 0.5
        
        let a = sqrt(radius * radius * 0.5)
        
        
        path.addArc(withCenter: centerP, radius: radius, startAngle: CGFloat.pi * 5 / 4, endAngle: CGFloat.pi * 7 / 4, clockwise: true)
        path.move(to: CGPoint(x: centerP.x + a, y: centerP.y + a))
        path.addLine(to: CGPoint(x: centerP.x - a, y: centerP.y - a))
        
        path.addArc(withCenter: centerP, radius: radius, startAngle: CGFloat.pi * 1 / 4, endAngle: CGFloat.pi * 3 / 4, clockwise: true)
        
        path.move(to: CGPoint(x: centerP.x + a, y: centerP.y - a))
        path.addLine(to: CGPoint(x: centerP.x - a, y: centerP.y + a))
        
        path.move(to: centerP)
        bgLayer0.path = path.cgPath
        bgLayer.path = path.cgPath
        addSublayer(bgLayer)
    }
    
    /// 更新进度
    private func setProgress(_ progress: CGFloat) {
        let color: UIColor = (progress == 1 ? .white : sandColor)
        holeLayer.backgroundColor = color.cgColor
        
        /// (0.1 -> 0.5)
        emitterLayer.lifetime = 1 + 0.25 * Float(1 - progress)
        let radius = (bounds.height) * 0.5  - lineWidth
        /// 顶部进度
        setTopProgress(progress, radius: radius)
        /// 底部进度
        setBottomProgress(progress, radius: radius)
    }
    
    /// 下部分锥形区域
    private func setBottomProgress(_ progress: CGFloat, radius: CGFloat) {
        
        /// 先快后慢的速度
        let realProgress = 0.8 * sqrt( 1 - pow((1 - progress), 2) )
        let bottomRadius = (bounds.height - lineWidth) * 0.5 * realProgress
        
        let offSetAnle = atan(bottomRadius / radius)
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: radius, startAngle: CGFloat.pi * 0.5 - offSetAnle, endAngle: CGFloat.pi * 0.5 + offSetAnle, clockwise: true)
         let center = CGPoint(x: bounds.midX, y: bounds.maxY - bottomRadius - lineWidth)
        path.addLine(to: center)

        bottomSandLayer.path = path.cgPath
    }
     
    /// 上部分的倒三角区域
    private func setTopProgress(_ p: CGFloat, radius: CGFloat) {
        
        if progress >= 1 {
            topSandLayer.path = UIBezierPath().cgPath
            return
        }
        /// 确定最大三角高度 a
        let a = sqrt(radius * radius * 0.5)
        let topOffset = lineWidth * 0.5 * sqrt(2)
        /// 倒三角底部顶点
        let origin = CGPoint(x: bounds.midX, y: bounds.midY - topOffset)
        
        /// 这里是先慢后快的速度减少高度
        let realHight = (a) * ( sqrt(1 - pow(progress, 2)) )
        let y = bounds.midY - realHight + topOffset
        let offsetX = realHight - topOffset * 0.5
        
        /// 绘制三角区域
        let leftP = CGPoint(x: bounds.midX - offsetX, y: y)
        let rightP = CGPoint(x: bounds.midX + offsetX, y: y)
        let path = UIBezierPath()
        path.move(to: origin)
        path.addLine(to: leftP)
        path.addLine(to: rightP)
        path.addLine(to: origin)
        topSandLayer.path = path.cgPath
        
//        let a = sqrt(radius * radius * 0.5)
//
//        let topOffset = lineWidth * 0.5 * sqrt(2)
//        let origin = CGPoint(x: bounds.midX, y: bounds.midY - topOffset)
//        let realHight = a + topOffset * 0.5
//        let y = bounds.midY - realHight
//        let offsetX = a - topOffset * 0.5
//        let leftP = CGPoint(x: bounds.midX - offsetX, y: y)
//        let rightP = CGPoint(x: bounds.midX + offsetX, y: y)
        ///方案四
//
//        if progress <= 0 {
//            let path = UIBezierPath()
//            path.move(to: origin)
//            path.addLine(to: leftP)
//            path.addLine(to: rightP)
//            path.addLine(to: origin)
//            topSandLayer.path = path.cgPath
//            return
//        }
//
//        let puzzlePath = UIBezierPath()
//        puzzlePath.move(to: origin)
//
//        let realFactorY: CGFloat /// 快 -> 慢 -> 快 的速度
//        let offset: CGFloat
//        if progress < 0.5 {
//            realFactorY = sqrt(0.5 * 0.5 - pow(0.5 - progress, 2))
//            offset = a
////
////            let centerP = CGPoint(x: bounds.midX, y: y  + realHight * realFactorY)
////            let offSet = progress * a * 2
////            //print("begn offSet == \(offSet)")
////            puzzlePath.addLine(to: leftP)
////            puzzlePath.addLine(to: CGPoint(x: bounds.midX - offSet, y: y))
////            puzzlePath.addLine(to: centerP)
////            puzzlePath.addLine(to: CGPoint(x: bounds.midX + offSet, y: y))
////            puzzlePath.addLine(to: rightP)
//        } else {
//            realFactorY = 1 - sqrt(0.5 * 0.5 - pow(progress - 0.5, 2))
//            offset = (1 - realFactorY) * a * 2
//
//        }
//        let centerP = CGPoint(x: bounds.midX, y:  y + realHight * realFactorY)
//
//        //print("end realFactorY == \(realFactorY)")
//        puzzlePath.addLine(to: CGPoint(x: bounds.midX - offset, y: bounds.midY - offset))
//        puzzlePath.addLine(to: centerP)
//        puzzlePath.addLine(to: CGPoint(x: bounds.midX + offset, y: bounds.midY - offset))
//        puzzlePath.addLine(to: origin)
//
//        topSandLayer.path = puzzlePath.cgPath
//        shapeLayer.path = puzzlePath.cgPath
//        shapeLayer.frame = bounds
//        shapeLayer.fillColor = UIColor.white.cgColor
//        topSandLayer.masksToBounds = true
//        topSandLayer.addSublayer(shapeLayer)

            /// 方案一
//            do {
//            let cycRadius: CGFloat = 50
//            let roundRect = CGRect(x: bounds.midX - cycRadius, y: bounds.midY - (1 - progress) * realHight - cycRadius * 2, width: cycRadius * 2, height: cycRadius * 2)
//            let roundPath = UIBezierPath(roundedRect: roundRect, cornerRadius: cycRadius)
//            shapeLayer.path = roundPath.cgPath
//            }
//
            /// 方案二
//            do {
//            let olverPath = UIBezierPath()
//            //let accelerW = sqrt(1 - pow(1 - progress, 2))
//            let accelerH = 1 - sqrt(1 - pow(progress, 2))
//            let acceler = sin(CGFloat.pi * progress * 0.5)  // progress > 0.25 ? accelerW : accelerH
//
//            var olverW: CGFloat = offsetX  * (acceler + 0.25)
//            if progress > 0.3 {
//                olverW += radius * (progress  - 0.3) * 1.1
//            } else if progress > 0.7 {
//                olverW += radius * 0.4 * 1.1
//            }
//            olverPath.move(to: CGPoint(x: bounds.midX - olverW, y: rightP.y - 5))
//            let offsetY = (progress > 0.8 ? 0.8 : progress) * radius + 5
//            olverPath.addQuadCurve(to: CGPoint(x: bounds.midX + olverW, y: rightP.y - 5), controlPoint: CGPoint(x: bounds.midX, y: rightP.y + offsetY + radius * (accelerH)))
//            shapeLayer.path = olverPath.cgPath
//            }
            
            /// 方案三
//            do {
//            let easyInAcceler = sqrt(1 - pow(1 - progress, 2))
//            let olverPath = UIBezierPath()
//
//            let roundRadius: CGFloat
//            let controlP: CGPoint
//            let criticalValue: CGFloat = 0.7
//            if progress < criticalValue {
//                 roundRadius = offsetX * easyInAcceler / sqrt(1 - pow(1 - criticalValue, 2))
//                 controlP = CGPoint(x: bounds.midX, y: rightP.y + realHight * (easyInAcceler + 0.2))
//            } else {
//                roundRadius = offsetX
//                controlP = CGPoint(x: bounds.midX, y: rightP.y + realHight * (easyInAcceler + 0.2) + (progress - criticalValue) * radius * 2)
//            }
//            olverPath.move(to: CGPoint(x: bounds.midX - roundRadius, y: rightP.y - 1))
//
//            olverPath.addQuadCurve(to: CGPoint(x: bounds.midX + roundRadius, y: rightP.y - 1), controlPoint: controlP)
//            shapeLayer.path = olverPath.cgPath
//            }
    }
}

// MARK: - extesions
extension CGColor {
    var uiColor: UIColor {
        UIColor(cgColor: self)
    }
}
extension UIImage {
    /// 创建一个圆形的图片
    static func roundColor(_ color: UIColor, wh: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: wh, height: wh)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        let path = UIBezierPath(ovalIn: rect)
        color.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
