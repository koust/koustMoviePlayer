//
//  koustMoviePlayerDidEndState.swift
//  koustMoviePlayer
//
//  Created by Batuhan Saygili on 11.11.2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import Foundation


public enum koustMoviePlayerDidEndState {
    // you can set the automatic shutdown when the video ends. Default manualClose
    
        // automatically returns to the page when the video ends
    case autoClose
        // remains on the movie page
    case manualClose
    
}
