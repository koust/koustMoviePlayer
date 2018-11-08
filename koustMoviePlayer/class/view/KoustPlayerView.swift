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
    
    public var videoURLS:[URL] = []
    public var autoPlay:KoustMoviePlayerState = .play
    
    
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
    

    
    func presentAVPlayer(){
        player                                      = AVPlayer(url:videoURLS.first!)
        playerVC.player                             = player
        playerVC.showsPlaybackControls              = false
        playerVC.entersFullScreenWhenPlaybackBegins = true
        UIApplication.topViewController()?.present(playerVC, animated: true){
            
            self.bottomContainer()
            self.playState()
//            self.preriodicTimeObsever()
        }
        
        
    }
    
    
    private func bottomContainer(){
        
        let y  = playerHeight - 35
        
        //Play And Pause Button
        
        self.playAndPauseBtn.frame  = CGRect(x: 30 , y: y, width: 25, height: 25)
        self.playAndPauseBtn.addTarget(self, action: #selector(playAndPauseBtnAction), for: .touchUpInside)
        
        
        self.playerVC.view.addSubview(playAndPauseBtn)
        
        
        //Rewind Button
        
        self.rewindBtn.frame       = CGRect(x: 90 , y: y , width:25 , height:25)
        self.rewindBtn.setImage(imageNamed("rewind-button"), for: .normal)
        
        self.playerVC.view.addSubview(rewindBtn)
        
        //Slider
        
        let sliderWith  = playerWidth - 90 - 160
        
        self.slider.frame                   = CGRect(x: 140, y: y, width: sliderWith, height: 25)
        self.slider.backgroundColor         = UIColor.clear
        self.slider.thumbTintColor          = UIColor.red
        self.slider.minimumTrackTintColor   = UIColor.red
        self.slider.tintColor               = UIColor.white
        self.slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        self.slider.addTarget(self, action: #selector(sliderTouchUpOutside), for: .touchUpInside)
        
        self.playerVC.view.addSubview(slider)
        
        // remainingTime
        
        let remaininTimeX               = sliderWith + 150
        
        self.remainingTime.frame        = CGRect(x: remaininTimeX, y: y, width: 95, height: 25)
        self.remainingTime.text         = "00:00:00"
        self.remainingTime.textColor    = UIColor.white
        
        
        self.playerVC.view.addSubview(remainingTime)
    }
    
    
    
    @objc func playAndPauseBtnAction(){
            self.playState()
    }
    
    @objc func sliderValueChanged(_ sender:UISlider){
            self.pause()
        
        let duration : CMTime = player?.currentItem!.duration ?? CMTime()
        let seconds : Float64 = CMTimeGetSeconds(duration) * Double(sender.value)
  
        hmsFrom(seconds: Int(seconds)) { hours, minutes, seconds in
            
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

        
        
        self.playerVC.player?.seek(to: seekToTime)
        
        self.play()
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
