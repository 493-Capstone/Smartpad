//
//  MainView.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-11.
//

import UIKit

class MainView: UIView {

    override func draw(_ rect: CGRect) {
        // TODO: Pass the true conn status
        drawConnStatus(status: ConnStatus.Unpaired)
//        drawConnStatus(status: ConnStatus.PairedAndConnected)
//        drawConnStatus(status: ConnStatus.PairedAndDisconnected)
    }

    /**
     * @brief: Draws the connection indicator in the top left of the screen
     */
    func drawConnStatus(status: ConnStatus) {
        var path = UIBezierPath()
        path = UIBezierPath(ovalIn: CGRect(x: 25, y: 50, width: 30, height: 30))
        switch status {
            case ConnStatus.Unpaired:
                UIColor.red.setFill()

            case ConnStatus.PairedAndDisconnected:
                UIColor.yellow.setFill()

            case ConnStatus.PairedAndConnected:
                UIColor.green.setFill()
        }

        path.lineWidth = 5
        path.stroke()
        path.fill()
    }
}
