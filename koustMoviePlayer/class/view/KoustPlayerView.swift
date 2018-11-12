//
//  KoustPlayerView.swift
//  koustMoviePlayer
//
//  Created by MacBook on 8.11.2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import AVKit
import AudioToolbox

open class KoustPlayerView: UIViewController {
    
    public var videoURLS:[URL]                = []
    public var skipButtonActive               = false
    public var skipButtonTitle                = "Skip"
    public var backButtonTitle                = ""
    public var skipButtonDuration:Double?
    public var delegate:KoustPlayerProtocol?
    
    public var didEndState:koustMoviePlayerDidEndState                   = .manualClose
    public var autoPlay:KoustMoviePlayerState                            = .play
    
    private var observer:Any?
    private var player:AVPlayer?
    private var playerVC        = KoustLandscapeAVPlayerController()
    private var _orientations   = UIInterfaceOrientationMask.landscape
    private var playerWidth     = UIScreen.main.bounds.width
    private var playerHeight    = UIScreen.main.bounds.height
    
    private var playAndPauseBtn = UIButton()
    private var rewindBtn       = UIButton()
    private var slider          = UISlider()
    private var remainingTime   = UILabel()
    private var skipBtn         = UIButton()
    private var thumbView       = UIView()
    private var thumbImage      = UIImageView()
    private var thumbCurrent    = UILabel()
    private var backButton      = UIButton()
    private var asset:AVURLAsset?
    private var generator:AVAssetImageGenerator?
    
    func presentAVPlayer(){
        player                                      = AVPlayer(url:videoURLS.first!)
        playerVC.player                             = player
        playerVC.showsPlaybackControls              = false
        asset                                       = AVURLAsset(url: videoURLS.first!)
        generator                                   = AVAssetImageGenerator(asset: asset!)
        generator?.appliesPreferredTrackTransform   = true

        
//        self.bottomContainer()
        UIApplication.topViewController()?.present(playerVC, animated: true){
                self.playState()
                self.bottomContainer()
                self.topContainer()
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
        self.playAndPauseBtn.widthAnchor.constraint(equalToConstant: 25).isActive                                         = true
        self.playAndPauseBtn.heightAnchor.constraint(equalToConstant: 25).isActive                                        = true
        
        self.playAndPauseBtn.addTarget(self, action: #selector(playAndPauseBtnAction), for: .touchUpInside)
        
        
        
        //Rewind Button
        
        self.rewindBtn.translatesAutoresizingMaskIntoConstraints  = false
        self.rewindBtn.setImage(imageNamed("rewind-button"), for: .normal)
        
        self.rewindBtn.leftAnchor.constraint(equalTo: self.playAndPauseBtn.rightAnchor, constant:   35).isActive           = true
        self.rewindBtn.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: -15).isActive           = true
        self.rewindBtn.widthAnchor.constraint(equalToConstant: 20).isActive                                                = true
        self.rewindBtn.heightAnchor.constraint(equalToConstant: 25).isActive                                               = true
        
        
        //Slider
        
        self.slider.translatesAutoresizingMaskIntoConstraints  = false
        
        self.slider.backgroundColor         = UIColor.clear
        self.slider.thumbTintColor          = UIColor.red
        self.slider.minimumTrackTintColor   = UIColor.red
        self.slider.maximumTrackTintColor   = UIColor.white
        self.slider.tintColor               = UIColor.white
        self.slider.maximumValue            = 0
        self.slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        self.slider.addTarget(self, action: #selector(sliderTouchUpInside), for: .touchUpInside)
        self.slider.addTarget(self, action: #selector(sliderTouchUpOutside), for: .touchUpOutside)
        
        
        self.slider.leftAnchor.constraint(equalTo: self.rewindBtn.rightAnchor, constant:   25).isActive                 = true
        self.slider.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: -15).isActive           = true
        self.slider.heightAnchor.constraint(equalToConstant: 30).isActive                                               = true
        self.slider.rightAnchor.constraint(equalTo: self.remainingTime.leftAnchor, constant:   -25).isActive            = true
        // remainingTime
        
        self.remainingTime.translatesAutoresizingMaskIntoConstraints  = false
  
        self.remainingTime.text         = "00:00"
        self.remainingTime.textColor    = UIColor.white
        
        
        self.remainingTime.rightAnchor.constraint(equalTo: self.playerVC.view.rightAnchor, constant:   -5).isActive            = true
        self.remainingTime.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: -15).isActive           = true
        self.remainingTime.widthAnchor.constraint(equalToConstant: 80).isActive                                                = true
        self.remainingTime.heightAnchor.constraint(equalToConstant: 30).isActive                                               = true
        
        if self.skipButtonDuration  != nil && self.skipButtonActive == true {
            self.skiptBtnView()
            self.skipBtnAnimationShow()
        }
        
        
    }
    
    
    private func topContainer(){
        self.backButton.translatesAutoresizingMaskIntoConstraints       = false
        self.backButton.setTitle("\(backButtonTitle)", for: .normal)
        self.backButton.setImage(imageNamed("left-arrow"), for: .normal)
        self.backButton.tintColor                                       = UIColor.white
        
        self.playerVC.view.addSubview(backButton)
        
        self.backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        self.backButton.leftAnchor.constraint(equalTo: self.playerVC.view.leftAnchor, constant: 20).isActive            = true
        self.backButton.topAnchor.constraint(equalTo: self.playerVC.view.topAnchor, constant: 15).isActive              = true
        self.backButton.heightAnchor.constraint(equalToConstant: 30).isActive                                           = true
    }
    
    
    private func skiptBtnView(){
        
        self.skipBtn.translatesAutoresizingMaskIntoConstraints      = false
        self.skipBtn.setTitle(skipButtonTitle, for: .normal)
        self.skipBtn.backgroundColor                                = UIColor.black
        self.skipBtn.alpha                                          = 0
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
            // vibration effect like netflix
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
            self.playState()
    }
    
    @objc func sliderValueChanged(_ sender:UISlider){
        self.pause()
        self.slider.maximumValue        = Float(self.playerVC.player?.currentItem?.duration.seconds ?? 0)
        let seconds : Float64           = Double(sender.value)
        
        let playbackLikelyToKeepUp = self.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp
        if playbackLikelyToKeepUp == false{
            showActivityIndicatory(uiView: self.playerVC.view)
        }else{
            self.removeIndicatory()
        }
        
        hmsFrom(seconds: (Int(player?.currentItem!.duration.seconds ?? 0) - Int(seconds))) { hours, minutes, seconds in
            
            let hours   = getStringFrom(seconds: hours)
            let minutes = getStringFrom(seconds: minutes)
            let seconds = getStringFrom(seconds: seconds)
            if hours == "00"{
                self.remainingTime.text = "\(minutes):\(seconds)"
            }else{
                self.remainingTime.text = "\(hours):\(minutes):\(seconds)"
            }
            
            self.createThumbView(currentThumbImage:self.getThumbImage(seconds:Double(sender.value))!,currentTime: self.remainingTime.text!)
        }
    }
    
    @objc func sliderTouchUpInside(_ sender: UISlider){
        let newCurrentTime: TimeInterval = Double(sender.value)
        let seekToTime: CMTime           = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 600)


        
        self.playerVC.player?.seek(to: seekToTime)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.thumbView.alpha      = 0
        }, completion: { _ in
            self.thumbView.removeFromSuperview()
        })
        
        
        if newCurrentTime > (skipButtonDuration ?? 0 ) {
            self.skipBtnAnimationHide()
        }else{
            self.skipBtnAnimationShow()
        }
        
        self.play()
    }
    
    
    
    @objc func sliderTouchUpOutside(_ sender:UISlider){
        let newCurrentTime: TimeInterval = Double(sender.value)
        let seekToTime: CMTime           = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 600)
        
        
        self.playerVC.player?.seek(to: seekToTime)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.thumbView.alpha      = 0
        }, completion: { _ in
            self.thumbView.removeFromSuperview()
        })
        
        
        if newCurrentTime > (skipButtonDuration ?? 0 ) {
            self.skipBtnAnimationHide()
        }else{
            self.skipBtnAnimationShow()
        }
        
        self.play()
    }
    
    @objc func setSkipDuration(){
        self.pause()
        
        
        let newCurrentTime: TimeInterval = Double(self.skipButtonDuration ?? 0)
        let seekToTime: CMTime           = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 600)
        
        self.slider.value                       = Float(seekToTime.seconds)
        self.slider.maximumValue                = Float(self.playerVC.player?.currentItem?.duration.seconds ?? 0)
       
        hmsFrom(seconds: (Int(player?.currentItem!.duration.seconds ?? 0) - Int(newCurrentTime))) { hours, minutes, seconds in
            let hours   = getStringFrom(seconds: hours)
            let minutes = getStringFrom(seconds: minutes)
            let seconds = getStringFrom(seconds: seconds)
            if hours == "00"{
                self.remainingTime.text = "\(minutes):\(seconds)"
            }else{
                self.remainingTime.text = "\(hours):\(minutes):\(seconds)"
            }
        }
        
        self.playerVC.player?.seek(to: seekToTime)
        self.play()
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.skipBtn.alpha      = 0
        }, completion: { _ in
            self.skipBtn.isHidden   = true
        })
    }
    
    @objc private func backButtonAction(){
        self.pause()
        player?.removeTimeObserver(observer)
        observer = nil
        
        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)

    }
    
    private func skipBtnAnimationShow(){
        UIView.animate(withDuration: 0.5, delay: 0.15, options: [], animations: {
        self.skipBtn.alpha      = 0.6
        }, completion: { _ in
            self.skipBtn.isHidden   = false
        })
    }
    
    private func skipBtnAnimationHide(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.skipBtn.alpha      = 0
        }, completion: { _ in
            self.skipBtn.isHidden   = true
        })
    }
    
    private func createThumbView(currentThumbImage:UIImage,currentTime:String){
        self.thumbView.backgroundColor                              = UIColor.black
        self.thumbView.alpha                                        = 1
        self.playerVC.view.addSubview(thumbView)
        
        
        self.thumbView.translatesAutoresizingMaskIntoConstraints    = false
        
        self.thumbView.centerXAnchor.constraint(equalTo: self.playerVC.view.centerXAnchor, constant: 0).isActive    = true
        self.thumbView.centerYAnchor.constraint(equalTo: self.playerVC.view.centerYAnchor, constant: 0).isActive    = true
        self.thumbView.widthAnchor.constraint(equalToConstant: self.playerVC.view.frame.width / 2).isActive         = true
        self.thumbView.heightAnchor.constraint(equalToConstant: self.playerVC.view.frame.height / 2).isActive       = true
        
        self.thumbCurrent.translatesAutoresizingMaskIntoConstraints = false
        
        self.thumbCurrent.textAlignment     = .center
        self.thumbCurrent.textColor         = UIColor.white
        self.thumbCurrent.text              = currentTime
        
        self.thumbView.addSubview(thumbCurrent)
        
        self.thumbCurrent.leftAnchor.constraint(equalTo: self.thumbView.leftAnchor, constant: 0).isActive           = true
        self.thumbCurrent.rightAnchor.constraint(equalTo: self.thumbView.rightAnchor, constant: 0).isActive         = true
        self.thumbCurrent.bottomAnchor.constraint(equalTo: self.thumbView.bottomAnchor, constant: 0).isActive       = true
        self.thumbCurrent.heightAnchor.constraint(equalToConstant: 30).isActive                                     = true
        
        self.thumbImage.translatesAutoresizingMaskIntoConstraints   = false
        
        self.thumbView.addSubview(thumbImage)
        
        self.thumbImage.image   = currentThumbImage
        
        self.thumbImage.leftAnchor.constraint(equalTo: self.thumbView.leftAnchor, constant: 0).isActive             = true
        self.thumbImage.rightAnchor.constraint(equalTo: self.thumbView.rightAnchor, constant: 0).isActive           = true
        self.thumbImage.topAnchor.constraint(equalTo: self.thumbView.topAnchor, constant: 0).isActive               = true
        self.thumbImage.bottomAnchor.constraint(equalTo: self.thumbCurrent.topAnchor, constant: 0).isActive         = true
        
    }
    
    
    private func playState(){
        switch autoPlay {
        case .play:
            self.play()
        case .pause:
            self.pause()
        }
        
        self.preriodicTimeObsever()
    }
    
    
    func play(){
        self.playerVC.player?.play()
        self.playAndPauseBtn.setImage(imageNamed("pause-button"), for: .normal)
        self.autoPlay   = .pause
    }
    
    func pause(){
        self.playerVC.player?.pause()
        self.playAndPauseBtn.setImage(imageNamed("play-button"), for: .normal)
        self.autoPlay   = .play
    }
    
    private func getThumbImage(seconds:Double) -> UIImage? {
        let timestamp = CMTime(seconds: seconds, preferredTimescale: 200)
        if let imageRef = try? generator?.copyCGImage(at: timestamp, actualTime: nil) {
            return UIImage(cgImage: imageRef!)
        } else {
            return nil
        }
    }
    
    private func removeIndicatory(){
        if let activityIndicatory = self.playerVC.view.viewWithTag(90) {
            activityIndicatory.removeFromSuperview()
        }
    }
    
    func preriodicTimeObsever(){
        
        
        observer = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: DispatchQueue.main) {
            [unowned self] time in
            
            let playbackLikelyToKeepUp = self.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false{
                showActivityIndicatory(uiView: self.playerVC.view)
            }else{
                self.removeIndicatory()
            }
            
            let timeString = String(format: "%02.2f", CMTimeGetSeconds(time))
            if timeString != "0.00" {
                if let totalDuration =  self.playerVC.player?.currentItem?.duration.seconds {
                    self.slider.maximumValue                = Float(totalDuration)
                    self.slider.setValue((Float(CMTimeGetSeconds(time))), animated: true)
                    
                    if CMTimeGetSeconds(time) > (self.skipButtonDuration ?? 0) {
                        self.skipBtnAnimationHide()
                    }else{
                        self.skipBtnAnimationShow()
                    }
                    

                    
                    hmsFrom(seconds: Int(totalDuration - CMTimeGetSeconds(time))){ hours, minutes, seconds in
                        let hours   = getStringFrom(seconds: hours)
                        let minutes = getStringFrom(seconds: minutes)
                        let seconds = getStringFrom(seconds: seconds)
                        if hours == "00"{
                            self.remainingTime.text = "\(minutes):\(seconds)"
                        }else{
                            self.remainingTime.text = "\(hours):\(minutes):\(seconds)"
                        }
                    }
                    
                    self.delegate?.koustPlayerPlaybackstimer(NSString: timeString)
                    if Float(totalDuration) == Float(CMTimeGetSeconds(time)) {
                        self.pause()
                        self.delegate?.koustPlayerPlaybackDidEnd()
                        
                        switch self.didEndState {
                            case .autoClose:
                                self.backButtonAction()
                            case .manualClose:
                                break
                        }
                    }
                }
            }
            
         
        }
    }
    
}
