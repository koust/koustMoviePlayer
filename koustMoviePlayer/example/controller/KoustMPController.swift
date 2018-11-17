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
        koustMPC.videoURLS.append(URL(string: "http://www.storiesinflight.com/js_videosub/jellies.mp4")!)
        //koustMPC.videoURLS.append(URL())
        // Do any additional setup after loading the view.
     
    }
    


    @IBAction func playAction(_ sender: Any) {
        koustMPC.autoPlay           = .play
        koustMPC.presentAVPlayer()
    }
    

}
