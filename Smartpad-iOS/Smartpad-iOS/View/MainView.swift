//
//  MainView.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-11.
//

import UIKit

class MainView: UIView {
    var status: ConnStatus = ConnStatus.Unpaired
    
    override func draw(_ rect: CGRect) {
        drawConnStatus()
    }

    /* Diameter in pixels */
    private let diameter = CGFloat(200.0)

    /* Line width in pixels*/
    private let lineWidth = CGFloat(5.0)

    /**
     * @brief: Draws the connection indicator in the center of the screen
     */
    func drawConnStatus() {
        var path = UIBezierPath()
        path = UIBezierPath(ovalIn: CGRect(x: self.bounds.midX - (diameter / 2) + 2 * lineWidth,
                                           y: self.bounds.midY - (diameter / 2) + 2 * lineWidth,
                                           width: diameter, height: diameter))
        switch status {
            case ConnStatus.Unpaired, ConnStatus.UnpairedAndBroadcasting:
                UIColor.red.setStroke()
                UIColor.red.setFill()

            case ConnStatus.PairedAndDisconnected:
                UIColor.yellow.setStroke()
                UIColor.yellow.setFill()

            case ConnStatus.PairedAndConnected:
                UIColor.green.setStroke()
                UIColor.green.setFill()
        }

        UIColor.black.setStroke()

        path.lineWidth = lineWidth
        path.stroke()
        path.fill()
    }
}
