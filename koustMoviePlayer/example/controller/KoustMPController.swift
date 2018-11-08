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

        koustMPC.videoURLS.append(URL(string: "http://techslides.com/demos/sample-videos/small.mp4")!)
        //koustMPC.videoURLS.append(URL())
        // Do any additional setup after loading the view.
    }
    


    @IBAction func playAction(_ sender: Any) {
        koustMPC.show()
    }
    
}
