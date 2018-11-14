//
//  KoustPlayerProtocol.swift
//  koustMoviePlayer
//
//  Created by Batuhan Saygili on 10.11.2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit

public protocol KoustPlayerDelegate: class {
//    func playerReady(player: Player)
//    func playerPlaybackStateDidChange(player: Player)
//    func playerBufferingStateDidChange(player: Player)
//    
//    func playerPlaybackWillStartFromBeginning(player: Player)
    func koustPlayerPlaybackDidEnd()
    func koustPlayerPlaybackstimer(NSString: String)
}
