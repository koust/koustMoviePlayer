//
//  KoustMPController.swift
//  koustMoviePlayer
//
//  Created by MacBook on 7.11.2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit

class KoustMPController: UIViewController {

    
        var koustMPC:KoustPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       koustMPC = KoustPlayerView()
        
    }


    @IBAction func playAction(_ sender: Any) {
        
        // Skipbuttonduration should be double value.
        koustMPC.skipButtonDuration = 5
        koustMPC.skipButtonActive   = true
        koustMPC.backButtonTitle    = "Big Fish"
        koustMPC.videoURL           = URL(string: "http://www.storiesinflight.com/js_videosub/jellies.mp4")!
        koustMPC.autoPlay           = .play
        koustMPC.presentAVPlayer()
    }
    

}
