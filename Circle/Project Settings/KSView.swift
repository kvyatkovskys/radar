//
//  KSView.swift
//  Circle
//
//  Created by Sergei Kviatkovskii on 17/09/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class KSView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawFigure(rect: CGRect) {
        let size = bounds.size

        let pLine1 = CGPoint(x: 0, y: 0)
        let pLine2 = CGPoint(x: 0, y: size.height)
        let pLine3 = CGPoint(x: size.width - 180, y: size.height)
        let pLine3_1 = CGPoint(x: size.width - 120, y: size.height)
        let pLine4 = CGPoint(x: size.width - 110, y: size.height - 15)
        let pLine4_1 = CGPoint(x: size.width - 100, y: size.height - 24)
        let pLine5 = CGPoint(x: size.width - 30, y: size.height - 24)
        let pLine5_1 = CGPoint(x: size.width - 20, y: size.height - 15)
        let pLine6 = CGPoint(x: size.width - 10, y: size.height)
        let pLine6_1 = CGPoint(x: size.width - 30, y: size.height)
        let pLine7 = CGPoint(x: size.width, y: size.height)
        let pLine8 = CGPoint(x: size.width, y: 0)
        
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.fillColor = UIColor.white.cgColor
        shapeLayer1.strokeColor = UIColor.clear.cgColor
        
        let linePath = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        linePath.move(to: pLine1)
        linePath.addLine(to: pLine2)
        linePath.addLine(to: pLine3)
        linePath.addLine(to: pLine3_1)
        linePath.addQuadCurve(to: pLine4, controlPoint: CGPoint(x: size.width - 110, y: size.height - 1))
        linePath.addQuadCurve(to: pLine4_1, controlPoint: CGPoint(x: size.width - 108, y: size.height - 23))
        linePath.addLine(to: pLine5)
        linePath.addQuadCurve(to: pLine5_1, controlPoint: CGPoint(x: size.width - 22, y: size.height - 23))
        linePath.addQuadCurve(to: pLine6, controlPoint: CGPoint(x: size.width - 20, y: size.height - 1))
        linePath.addLine(to: pLine6_1)
        linePath.addLine(to: pLine7)
        linePath.addLine(to: pLine8)
        linePath.close()
        
        shapeLayer1.path = linePath.cgPath
        
        layer.addSublayer(shapeLayer1)
    }
    
    override func draw(_ rect: CGRect) {
        drawFigure(rect: rect)
    }
}
