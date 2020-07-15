//
//  ViewController.swift
//  Sandglass
//
//  Created by zhangshangen on 07/13/2020.
//  Copyright (c) 2020 zhangshangen. All rights reserved.
//

import UIKit
import Sandglass

class ViewController: UIViewController {
    lazy var layer: SandglassLayer = {
        $0.bgLineWidth = 5
        $0.bgStrokeColor = UIColor.hexColor(0xF0F0F2, alpha: 0.5)
        $0.sandColor = UIColor.hexColor(0xFF8000, alpha: 0.5)
        return $0
    }( SandglassLayer() )

    override func viewDidLoad() {
        super.viewDidLoad()
        layer.frame = CGRect(origin: .init(x: 100, y: 200), size: CGSize(width: 100, height: (48 + 5) * 2))
        view.layer.addSublayer(layer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        layer.progress = 0
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setProgress(0)
        layer.beginAnimate()
    }
    
    
    func setProgress(_ progress: CGFloat) {
        if progress > 1.1 {
            layer.endAnimate()
            return
        }
        layer.progress =  progress
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setProgress(progress + 0.01)
        }
    }
}



extension UIColor {
    static func hexColor(_ hex: Int, alpha: CGFloat) -> UIColor {
        let red   =  Double((hex & 0xFF0000) >> 16) / 255.0
        let green =  Double((hex & 0xFF00)   >> 8 ) / 255.0
        let blue  =  Double( hex & 0xFF   ) / 255.0
        return UIColor.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: alpha)
    }
}
