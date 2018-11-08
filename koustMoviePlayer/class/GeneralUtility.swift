//
//  GeneralUtility.swift
//  koustMoviePlayer
//
//  Created by MacBook on 8.11.2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit

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
