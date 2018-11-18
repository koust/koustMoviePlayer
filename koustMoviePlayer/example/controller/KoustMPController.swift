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
        
       koustMPC = KoustPlayerView(videoURL: URL(string: "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_10mb.mp4")!)
        
    }


    @IBAction func playAction(_ sender: Any) {
        
        // Skipbuttonduration should be double value.
        koustMPC.skipButtonDuration = 5
        koustMPC.skipButtonActive   = true
        koustMPC.backButtonTitle    = "Cartoon Movie | For Kids +4"
        koustMPC.autoPlay           = .play
        koustMPC.presentAVPlayer()
    }
    

}
