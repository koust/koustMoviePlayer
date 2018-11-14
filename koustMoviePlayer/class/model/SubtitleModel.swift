//
//  SubtitleModel.swift
//  koustMoviePlayer
//
//  Created by Batuhan Saygili on 13.11.2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import Foundation

class SubtitleModel: NSObject,Codable {
    var index:Int?
    var startToTime:Double?
    var endToTime:Double?
    var text:String?
    
    override init() {
        
        super.init()
    }
}
