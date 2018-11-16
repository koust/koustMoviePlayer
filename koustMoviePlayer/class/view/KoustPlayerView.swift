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

open class KoustPlayerView: UIViewController,KoustSubtitleDelegate {

    
    
    public var videoURLS:[URL]                = []
    public var skipButtonActive               = false
    public var skipButtonTitle                = "Skip"
    public var backButtonTitle                = ""
    public var animationDuration              = 4
    public var skipButtonDuration:Double?
    public var delegate:KoustPlayerDelegate?
    
    public var didEndState:koustMoviePlayerDidEndState                   = .manualClose
    public var autoPlay:KoustMoviePlayerState                            = .play
    
    private var subtitleState:KoustMPSubtitleState                       = .starToTime
    
    private var observer:Any?
    private var player:AVPlayer?
    @objc private var playerVC        = KoustLandscapeAVPlayerController()
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
    
    
    private var subtitleList:[SubtitleModel] = []
    private var subtitleCount    = 0
    private var animationCount    = 0
    private var isAnimationActive = true
    private var asset:AVURLAsset?
    private var generator:AVAssetImageGenerator?
    
    func presentAVPlayer(){
        player                                      = AVPlayer(url:videoURLS.first!)
        playerVC.player                             = player
        playerVC.showsPlaybackControls              = false
        asset                                       = AVURLAsset(url: videoURLS.first!)
        generator                                   = AVAssetImageGenerator(asset: asset!)
        generator?.appliesPreferredTrackTransform   = true
        
        

        let subTitle        = KoustSubTitleController(delegate: self)
        subTitle.setSubtitle(forResource: "sample")
        
        
        DispatchQueue.main.async(execute: {
            UIApplication.topViewController()?.present(self.playerVC, animated: true){
                
                    self.playState()
                    self.bottomContainer()
                    self.topContainer()
            }
        })
        
    }
    

    
    private func bottomContainer(){
        
        let mainView = UIView()
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.mainHandleTap))
        mainView.addGestureRecognizer(tap)
        
        self.playerVC.view.addSubview(mainView)
        
        mainView.leftAnchor.constraint(equalTo: self.playerVC.view.leftAnchor, constant: 0).isActive     = true
        mainView.rightAnchor.constraint(equalTo: self.playerVC.view.rightAnchor, constant: 0).isActive   = true
        mainView.topAnchor.constraint(equalTo: self.playerVC.view.topAnchor, constant: 0).isActive       = true
        mainView.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: 0).isActive = true
        
        
        //Play And Pause Button View
        self.playAndPauseBtn.translatesAutoresizingMaskIntoConstraints  = false
        
        self.playerVC.view.addSubview(playAndPauseBtn)
        self.playerVC.view.addSubview(rewindBtn)
        self.playerVC.view.addSubview(slider)
        self.playerVC.view.addSubview(remainingTime)
        
        self.playAndPauseBtn.leftAnchor.constraint(equalTo: self.playerVC.view.leftAnchor, constant: 25).isActive         = true
        self.playAndPauseBtn.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: -15).isActive    = true
        self.playAndPauseBtn.widthAnchor.constraint(equalToConstant: 25).isActive                                         = true
        self.playAndPauseBtn.heightAnchor.constraint(equalToConstant: 25).isActive                                        = true
        
        self.playAndPauseBtn.addTarget(self, action: #selector(playAndPauseBtnAction), for: .touchUpInside)
        
        
        
        //Rewind Button View
        
        self.rewindBtn.translatesAutoresizingMaskIntoConstraints  = false
        self.rewindBtn.setImage(imageNamed("rewind-button"), for: .normal)
        
        self.rewindBtn.leftAnchor.constraint(equalTo: self.playAndPauseBtn.rightAnchor, constant:   35).isActive           = true
        self.rewindBtn.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: -15).isActive           = true
        self.rewindBtn.widthAnchor.constraint(equalToConstant: 20).isActive                                                = true
        self.rewindBtn.heightAnchor.constraint(equalToConstant: 25).isActive                                               = true
        
        
        //Slider View
        
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
        
        // remainingTime View
        
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
    
    // handle tap for player view
    @objc private func mainHandleTap(){
        self.animationCount     =  0
        allViewShow()
    }
    
    private func allViewShow(){
        let alphaValue:CGFloat          =  1
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.slider.alpha           = alphaValue
            self.remainingTime.alpha    = alphaValue
            self.playAndPauseBtn.alpha  = alphaValue
            self.rewindBtn.alpha        = alphaValue
            self.backButton.alpha       = alphaValue
        }, completion: { _ in
        })
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
            self.getThumbImage(seconds:Double(sender.value))
            self.createThumbView(currentTime: self.remainingTime.text!)
        }
    }
    
    @objc func sliderTouchUpInside(_ sender: UISlider){
        self.animationCount              =  0
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
    
    private func createThumbView(currentThumbImage:UIImage = UIImage(),currentTime:String){
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
    
    private func getThumbImage(seconds:Double)  {
        let timestamp = CMTime(seconds: seconds, preferredTimescale: 200)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                if let imageRef = try? self.generator?.copyCGImage(at: timestamp, actualTime: nil) {
                    
                    DispatchQueue.main.async {
                
                        self.thumbImage.image = UIImage(cgImage: imageRef!)
                    }
                } else {
                    
                    DispatchQueue.main.async {
                    //return nil
                    }
                }
            }
        }
    }
    
    private func removeIndicatory(){
        if let activityIndicatory = self.playerVC.view.viewWithTag(90) {
            activityIndicatory.removeFromSuperview()
        }
    }
    
    public func subtitleList(list: [SubtitleModel]) {
        print(list)
        self.subtitleList = list
    }
    
    private func showSubtitle(currentTime:Double){
        

        
        if self.subtitleList.count > 0  && self.subtitleCount < self.subtitleList.count {
            
            if subtitleState == .starToTime {
                if (self.subtitleList[self.subtitleCount].startToTime ?? 0) <= currentTime {
                    print(self.subtitleList[self.subtitleCount].text)
                    self.subtitleState   = .endToTime
                }
            }
            
            
            if subtitleState == .endToTime {
                if (self.subtitleList[self.subtitleCount].endToTime ?? 0) <= currentTime {
                    print("silindi")
                    
                    if self.subtitleCount < self.subtitleList.count {
                        print(subtitleCount)
                        self.subtitleState   = .starToTime
                        self.subtitleCount += 1
                        
                        print(subtitleCount)
                    }
                }
            }
            
        }
    }
    
    func preriodicTimeObsever(){
        
        
        observer = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 60), queue: DispatchQueue.main) {
            [unowned self] time in
            
            // Activity Indicator part
            let playbackLikelyToKeepUp = self.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false{
                showActivityIndicatory(uiView: self.playerVC.view)
            }else{
                self.removeIndicatory()

            }
            self.showSubtitle(currentTime: time.seconds)
          
            
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
                        self.allViewShow()
                        switch self.didEndState {
                            case .autoClose:
                                self.backButtonAction()
                            case .manualClose:
                                break
                        }
                    }
                    
                    // We hiding all views
                    if self.animationDuration == (self.animationCount / 100) && self.isAnimationActive {
                        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                            self.slider.alpha           = 0
                            self.remainingTime.alpha    = 0
                            self.playAndPauseBtn.alpha  = 0
                            self.rewindBtn.alpha        = 0
                            self.backButton.alpha       = 0
                        }, completion: { _ in
                        })
                    }
                    
                    self.animationCount += 1
                }
            }
            
         
        }
    }
    
}
