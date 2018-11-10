//
//  KoustMoviewPlayerController.swift
//  koustMoviePlayer
//
//  Created by @koust - Batuhan SAYGILI on 7.11.2018.
//  Copyright © 2018 @koust. All rights reserved.
//

import UIKit

open class KoustMoviewPlayerController: KoustPlayerView {


    
    public func show(){
        
        presentAVPlayer()
        
    }
    

    
    
    public func close(){
        
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
