//
//  KoustPlayerView.swift
//  koustMoviePlayer
//
//  Created by MacBook on 8.11.2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import AVKit

open class KoustPlayerView: UIViewController {
    
    public var videoURLS:[URL]                = []
    public var autoPlay:KoustMoviePlayerState = .play
    public var skipButtonActive               = false
    public var skipButtonTitle                = "Skip"
    public var skipButtonDuration:Double?
    
    
    private var observer:Any?
    private var player:AVPlayer?
    private var playerVC        = KoustLandscapeAVPlayerController()
    private var _orientations   = UIInterfaceOrientationMask.landscape
    private var playerWidth     = UIScreen.main.bounds.width
    private var playerHeight    = UIScreen.main.bounds.height
    private var interval        = CMTime(seconds: 0.1,preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    
    private var playAndPauseBtn = UIButton()
    private var rewindBtn       = UIButton()
    private var slider          = UISlider()
    private var remainingTime   = UILabel()
    private var skipBtn         = UIButton()

    
    func presentAVPlayer(){
        player                                      = AVPlayer(url:videoURLS.first!)
        playerVC.player                             = player
        playerVC.showsPlaybackControls              = false
        
        
        self.bottomContainer()
        UIApplication.topViewController()?.present(playerVC, animated: true){
            
            self.bottomContainer()
            self.playState()
            self.preriodicTimeObsever()
        }
        
        
    }
    
    
    private func bottomContainer(){
        
        
        //Play And Pause Button
        self.playAndPauseBtn.translatesAutoresizingMaskIntoConstraints  = false
//        self.playAndPauseBtn.frame  = CGRect(x: 30 , y: y, width: 25, height: 25)
        
        self.playerVC.view.addSubview(playAndPauseBtn)
        self.playerVC.view.addSubview(rewindBtn)
        self.playerVC.view.addSubview(slider)
        self.playerVC.view.addSubview(remainingTime)
        
        self.playAndPauseBtn.leftAnchor.constraint(equalTo: self.playerVC.view.leftAnchor, constant: 25).isActive         = true
        self.playAndPauseBtn.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: -15).isActive    = true
        self.playAndPauseBtn.widthAnchor.constraint(equalToConstant: 30).isActive                                         = true
        self.playAndPauseBtn.heightAnchor.constraint(equalToConstant: 30).isActive                                        = true
        
        self.playAndPauseBtn.addTarget(self, action: #selector(playAndPauseBtnAction), for: .touchUpInside)
        
        
        
        //Rewind Button
        
        self.rewindBtn.translatesAutoresizingMaskIntoConstraints  = false
        self.rewindBtn.setImage(imageNamed("rewind-button"), for: .normal)
        
        self.rewindBtn.leftAnchor.constraint(equalTo: self.playAndPauseBtn.rightAnchor, constant:   25).isActive           = true
        self.rewindBtn.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: -15).isActive           = true
        self.rewindBtn.widthAnchor.constraint(equalToConstant: 30).isActive                                                = true
        self.rewindBtn.heightAnchor.constraint(equalToConstant: 30).isActive                                               = true
        
        
        //Slider
        
        self.slider.translatesAutoresizingMaskIntoConstraints  = false
        
        self.slider.backgroundColor         = UIColor.clear
        self.slider.thumbTintColor          = UIColor.red
        self.slider.minimumTrackTintColor   = UIColor.red
        self.slider.maximumTrackTintColor   = UIColor.white
        self.slider.tintColor               = UIColor.white
        self.slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        self.slider.addTarget(self, action: #selector(sliderTouchUpOutside), for: .touchUpInside)
        
        
        self.slider.leftAnchor.constraint(equalTo: self.rewindBtn.rightAnchor, constant:   25).isActive                 = true
        self.slider.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: -15).isActive           = true
        self.slider.heightAnchor.constraint(equalToConstant: 30).isActive                                               = true
        self.slider.rightAnchor.constraint(equalTo: self.remainingTime.leftAnchor, constant:   -25).isActive            = true
        // remainingTime
        
        self.remainingTime.translatesAutoresizingMaskIntoConstraints  = false
  
        self.remainingTime.text         = "00:00:00"
        self.remainingTime.textColor    = UIColor.white
        
        
        self.remainingTime.rightAnchor.constraint(equalTo: self.playerVC.view.rightAnchor, constant:   -5).isActive            = true
        self.remainingTime.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: -15).isActive           = true
        self.remainingTime.widthAnchor.constraint(equalToConstant: 90).isActive                                                = true
        self.remainingTime.heightAnchor.constraint(equalToConstant: 30).isActive                                               = true
        
        if self.skipButtonDuration  != nil && self.skipButtonActive == true {
            self.skiptBtnView()
        }
        
        
    }
    
    private func skiptBtnView(){
        
        self.skipBtn.translatesAutoresizingMaskIntoConstraints      = false
        self.skipBtn.setTitle(skipButtonTitle, for: .normal)
        self.skipBtn.backgroundColor                                = UIColor.black
        self.skipBtn.alpha                                          = 0.6
        self.skipBtn.tintColor                                      = UIColor.white
        self.skipBtn.layer.borderColor                              = UIColor.white.cgColor
        self.skipBtn.layer.borderWidth                              = 1
        self.skipBtn.contentMode                                    = .center
        self.skipBtn.layer.cornerRadius                             = 3
        self.skipBtn.addTarget(self, action: #selector(setSkipDuration), for: .touchUpInside)
        
        
        self.playerVC.view.addSubview(skipBtn)
        
        self.skipBtn.rightAnchor.constraint(equalTo: self.playerVC.view.rightAnchor, constant: -25).isActive                   = true
        self.skipBtn.bottomAnchor.constraint(equalTo: self.remainingTime.topAnchor, constant: -30).isActive                    = true
        self.skipBtn.widthAnchor.constraint(equalToConstant: 60).isActive                                                      = true
    }
    
    
    
    @objc func playAndPauseBtnAction(){
            self.playState()
    }
    
    @objc func sliderValueChanged(_ sender:UISlider){
            self.pause()
        
        let duration : CMTime = player?.currentItem!.duration ?? CMTime()
        let seconds : Float64 = CMTimeGetSeconds(duration) * Double(sender.value)
  
        hmsFrom(seconds: (Int(player?.currentItem!.duration.seconds ?? 0) - Int(seconds))) { hours, minutes, seconds in
            
            let hours   = getStringFrom(seconds: hours)
            let minutes = getStringFrom(seconds: minutes)
            let seconds = getStringFrom(seconds: seconds)
            
            
            self.remainingTime.text = "\(hours):\(minutes):\(seconds)"
        }
    }
    
    @objc func sliderTouchUpOutside(_ sender: UISlider){
        let duration : CMTime            = player?.currentItem!.duration ?? CMTime()
        let newCurrentTime: TimeInterval = Double(sender.value) * CMTimeGetSeconds(duration)
        let seekToTime: CMTime           = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 600)
        interval                         = seekToTime

        if newCurrentTime > (skipButtonDuration ?? 0 ) {
            self.skipBtnAnimationHide()
        }else{
            self.skipBtnAnimationShow()
        }
        
        self.playerVC.player?.seek(to: seekToTime)
        
        self.play()
    }
    
    
    @objc func setSkipDuration(){
        self.pause()
        
        
        let newCurrentTime: TimeInterval = Double(self.skipButtonDuration ?? 0)
        let seekToTime: CMTime           = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 600)
        
       
        hmsFrom(seconds: (Int(player?.currentItem!.duration.seconds ?? 0) - Int(newCurrentTime))) { hours, minutes, seconds in
            let hours   = getStringFrom(seconds: hours)
            let minutes = getStringFrom(seconds: minutes)
            let seconds = getStringFrom(seconds: seconds)
            self.remainingTime.text = "\(hours):\(minutes):\(seconds)"
        }
        
        self.playerVC.player?.seek(to: seekToTime)
        
        self.play()
        
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.skipBtn.alpha      = 0
        }, completion: { _ in
            self.skipBtn.isHidden   = true
        })
    }
    
    private func skipBtnAnimationShow(){
        self.skipBtn.isHidden   = false
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
        self.skipBtn.alpha      = 0.6
        }, completion: { _ in
        })
    }
    
    private func skipBtnAnimationHide(){
        self.skipBtn.isHidden   = false
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.skipBtn.alpha      = 0
        }, completion: { _ in
            self.skipBtn.isHidden   = true
        })
    }
    
    
    
    private func playState(){
        switch autoPlay {
        case .play:
            self.play()
        case .pause:
            self.pause()
        }
        
    }
    
    
    private func play(){
        self.playerVC.player?.play()
        self.playAndPauseBtn.setImage(imageNamed("pause-button"), for: .normal)
        self.autoPlay   = .pause
    }
    
    private func pause(){
        self.playerVC.player?.pause()
        self.playAndPauseBtn.setImage(imageNamed("play-button"), for: .normal)
        self.autoPlay   = .play
    }
    
    
    func preriodicTimeObsever(){
        
        if let observer = self.observer{
            //removing time obse
            player?.removeTimeObserver(observer)
//            observer = nil
        }
        
        observer = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            
            
            self?.slider.maximumValue = Float(CGFloat(CMTimeGetSeconds(self?.playerVC.player?.currentItem?.duration ?? CMTime())))
            
            let remainingDuration     = Int(CGFloat(CMTimeGetSeconds(self?.playerVC.player?.currentItem?.duration ?? CMTime()))) - Int(CGFloat(CMTimeGetSeconds(self?.playerVC.player?.currentItem?.currentTime() ?? CMTime())))
            
            hmsFrom(seconds: remainingDuration) { hours, minutes, seconds in
                
                let hours = getStringFrom(seconds: hours)
                let minutes = getStringFrom(seconds: minutes)
                let seconds = getStringFrom(seconds: seconds)
                
                
                self?.remainingTime.text = "\(hours):\(minutes):\(seconds)"
            }
            
            let sliderValue : Float64 = CMTimeGetSeconds(time)
            //this is the slider value update if you are using UISlider.
            self?.slider.setValue(Float(sliderValue), animated: true)
            
            let playbackLikelyToKeepUp = self?.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false{
                
                //Here start the activity indicator inorder to show buffering
            }else{
                //stop the activity indicator
            }
        }
    }
}
