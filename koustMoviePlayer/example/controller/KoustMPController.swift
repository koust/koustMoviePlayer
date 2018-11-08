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

        koustMPC.videoURLS.append(URL(string: "https://r2---sn-4g5e6nle.googlevideo.com/videoplayback?key=cms1&dur=24.241&ratebypass=yes&source=youtube&lmt=1386471174027501&requiressl=yes&ipbits=0&signature=0933B3A692B93832B97F6ABE0558A8793F069205.4C3769C3EC3D3BBA9198C2A0F32A2FD9F421BF85&gir=yes&fvip=2&c=WEB&id=o-AFKaAtFzZkoiIU3Tx-Zh4H-PfTFF_JAvrb31G2EjtlXW&sparams=clen,dur,ei,expire,gir,id,ip,ipbits,ipbypass,itag,lmt,mime,mip,mm,mn,ms,mv,pl,ratebypass,requiressl,source&ip=2001:41d0:d:f87::&itag=18&ei=jYnkW_KTF4yLhAfz0oqABw&pl=22&mime=video/mp4&expire=1541725677&clen=1236178&title=Steve+Ballmer+Developers&redirect_counter=1&rm=sn-25gkz7l&fexp=23763603&req_id=e2b38481e6c2a3ee&cms_redirect=yes&ipbypass=yes&mip=176.33.116.185&mm=31&mn=sn-4g5e6nle&ms=au&mt=1541704021&mv=m")!)
        //koustMPC.videoURLS.append(URL())
        // Do any additional setup after loading the view.
    }
    


    @IBAction func playAction(_ sender: Any) {
        koustMPC.show()
    }
    
}
