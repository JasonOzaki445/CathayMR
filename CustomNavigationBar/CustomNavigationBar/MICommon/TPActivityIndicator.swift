//
//  TPActivityIndicator.swift
//  CustomNavigationBar
//
//  Created by Jason Chen on 2019/9/9.
//  Copyright © 2019 Jason Chen. All rights reserved.
//

import Foundation
import UIKit

//
// MARK: - TPActivityIndicator
//

/// Runs show the activity indicator or remove it.
class TPActivityIndicator {
    //
    // MARK: - Internal static variables
    //
    internal static var messageLabel = UILabel()
    internal static var messageFrame = UIView()
    internal static var activityIndicator = UIActivityIndicatorView()
    
    //
    // MARK: - Internal Methods
    //
    /// This method will show activity indicator with message.
    internal static func showActivityIndicatory(message: String, showIndicator: Bool) {
        let indicatorView = UIApplication.shared.delegate?.window!!.rootViewController?.view
        
        indicatorView?.isUserInteractionEnabled = false
        
        messageLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        messageLabel.text = message
        messageLabel.textColor = UIColor.white
        messageFrame = UIView(frame: CGRect(x: indicatorView!.frame.midX - 90, y: indicatorView!.frame.midY - 25 , width: 180, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if showIndicator {
            activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(messageLabel)
        indicatorView!.addSubview(messageFrame)
    }
    
    /// This method will remove activity indicator from super view.
    internal static func removeActivityIndicatory() {
        let indicatorView = UIApplication.shared.delegate?.window!!.rootViewController?.view
        _ = indicatorView?.subviews.filter({ (view) -> Bool in
            if view == TPActivityIndicator.messageFrame {
                view.removeFromSuperview()
            }
            return false
        })
        
        TPActivityIndicator.messageFrame.removeFromSuperview()
        indicatorView?.isUserInteractionEnabled = true
    }
    
    deinit {
        
    }
}
