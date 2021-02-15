//
//  TimeLineTableView.swift
//  ToDoList
//
//  Created by 최광현 on 2021/02/14.
//

import UIKit

class TimeLineTableView: UITableView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        self.backgroundColor = .clear
        self.setTimeLineLayer()
    }
    
    private func drawTimeLine() -> UIBezierPath {
        let timeLine = UIBezierPath()
        timeLine.move(to: CGPoint(x: 80, y: 0))
        timeLine.addLine(to: CGPoint(x: 80, y: self.frame.height))
        timeLine.close()
        return timeLine
    }
    
    private func setTimeLineLayer() {
        let timeLineLayer = CAShapeLayer()
        timeLineLayer.path = self.drawTimeLine().cgPath
        timeLineLayer.lineWidth = 3
        timeLineLayer.strokeColor = UIColor.brown.cgColor
        self.layer.insertSublayer(timeLineLayer, at: 0)
    }

}
