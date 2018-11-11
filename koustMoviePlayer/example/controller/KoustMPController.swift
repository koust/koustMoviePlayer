//
//  KoustMPController.swift
//  koustMoviePlayer
//
//  Created by MacBook on 7.11.2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit

class KoustMPController: UIViewController {

    

    let koustMPC = KoustMoviewPlayerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Skipbuttonduration should be double value.
        koustMPC.skipButtonDuration =  7
        koustMPC.skipButtonActive   = true
        koustMPC.backButtonTitle    = "Çizgi Film Sahnesi"
        koustMPC.videoURLS.append(URL(string: "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_2mb.mp4")!)
        //koustMPC.videoURLS.append(URL())
        // Do any additional setup after loading the view.
     
    }
    


    @IBAction func playAction(_ sender: Any) {
        koustMPC.autoPlay           = .play
        koustMPC.presentAVPlayer()
    }
    

}
