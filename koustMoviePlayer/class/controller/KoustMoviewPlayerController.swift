//
//  KoustMoviewPlayerController.swift
//  koustMoviePlayer
//
//  Created by @koust - Batuhan SAYGILI on 7.11.2018.
//  Copyright © 2018 @koust. All rights reserved.
//

import UIKit
import AVKit

open class KoustMoviewPlayerController: UIViewController {

    public var videoURLS:[URL] = []
    
    private var player:AVPlayer?
    private var playerVC = KoustLandscapeAVPlayerController()
    private var _orientations = UIInterfaceOrientationMask.landscape
    
    private var playAndPauseBtn = UIButton()
    
    public func show(){
        
        
        player                                      = AVPlayer(url:videoURLS.first!)
        playerVC.player                             = player
        playerVC.showsPlaybackControls              = false
        playerVC.entersFullScreenWhenPlaybackBegins = true
        
        UIApplication.topViewController()?.present(playerVC, animated: true){
            self.playerVC.player?.play()
            
        }
        
        
        self.bottomContainer()
        
    }
    
    
    private func close(){
        
    }
    
    private func bottomContainer(){
        self.playAndPauseBtn.translatesAutoresizingMaskIntoConstraints      = false
        
        self.playAndPauseBtn.setTitle("Play", for: .normal)
        
        self.playAndPauseBtn.leftAnchor.constraint(equalTo: playerVC.view.leftAnchor, constant: 0).isActive     = true
        self.playAndPauseBtn.bottomAnchor.constraint(equalTo: playerVC.view.bottomAnchor, constant: 5).isActive = true
        self.playAndPauseBtn.widthAnchor.constraint(equalToConstant: 25).isActive    = true
        self.playAndPauseBtn.heightAnchor.constraint(equalToConstant: 25).isActive   = true
        
        self.playerVC.view.addSubview(playAndPauseBtn)
    }
}




extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}
