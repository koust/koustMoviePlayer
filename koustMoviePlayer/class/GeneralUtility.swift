//
//  GeneralUtility.swift
//  koustMoviePlayer
//
//  Created by MacBook on 8.11.2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import AVKit

func imageNamed(_ name: String) -> UIImage {
    let cls = KoustPlayerView.self
    var bundle = Bundle(for: cls)
    let traitCollection = UITraitCollection(displayScale: 3)
    
    if let resourceBundle = bundle.resourcePath.flatMap({ Bundle(path: $0 + "/koustMoviePlayer.bundle") }) {
        bundle = resourceBundle
    }
    
    guard let image = UIImage(named: name, in: bundle, compatibleWith: traitCollection) else {
        return UIImage()
    }
    return image
}



func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int)->()) {
    
    completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    
}

func getStringFrom(seconds: Int) -> String {
    
    return seconds < 10 ? "0\(seconds)" : "\(seconds)"
}


func videoPreviewUIImage(moviePath: URL,seconds:Double) -> UIImage? {
    let asset = AVURLAsset(url: moviePath)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = false
    let timestamp = CMTime(seconds: seconds, preferredTimescale: 100)
    if let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil) {
        return UIImage(cgImage: imageRef)
    } else {
        return nil
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



func showActivityIndicatory(uiView: UIView) {
    let container: UIView = UIView()
    container.frame  = uiView.frame
    container.center = uiView.center
    container.tag    = 90
    container.backgroundColor = UIColor.clear
    
    let loadingView: UIView = UIView()
    loadingView.frame  = CGRect(x:0, y:0, width:80, height:80)
    loadingView.center = uiView.center
    loadingView.backgroundColor    = UIColor.clear.withAlphaComponent(0.4)
    loadingView.clipsToBounds      = true
    loadingView.layer.cornerRadius = 10
    
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    actInd.frame = CGRect(x:0.0, y:0.0, width:40.0, height:40.0);
    actInd.style =
        UIActivityIndicatorView.Style.whiteLarge
    actInd.center = CGPoint(x:loadingView.frame.size.width / 2,
                            y:loadingView.frame.size.height / 2);
    loadingView.addSubview(actInd)
    container.addSubview(loadingView)
    uiView.addSubview(container)
    actInd.startAnimating()
}


