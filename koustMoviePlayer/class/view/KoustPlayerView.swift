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

public class KoustPlayerView: KoustMoviewPlayerController,KoustSubtitleDelegate {

    
    
    public var videoURL:URL!
    public var skipButtonActive               = false
    public var skipButtonTitle                = "Skip"
    public var backButtonTitle                = ""
    public var animationDuration              = 4
    public var rewindDuration                 = 10
    public var subtitleResourceName           = ""
    public var skipButtonDuration:Double!
    public var delegate:KoustPlayerDelegate?
    
    public var didEndState:koustMoviePlayerDidEndState                   = .manualClose
    public var autoPlay:KoustMoviePlayerState                            = .play
    
    private var subtitleState:KoustMPSubtitleState                       = .starToTime
    
    private var observer:Any?
    private var player:AVPlayer?
    @objc private var playerVC  = KoustLandscapeAVPlayerController()
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
    private var subtitle        = UILabel()

    private var thumbCenterXCons:NSLayoutConstraint!
    private var subtitleBottomCons:NSLayoutConstraint!
    private var subtitleNotSliderBottomCons:NSLayoutConstraint!
    
    private var subtitleList:[SubtitleModel] = []
    private var subtitleCount                = 0
    private var animationCount               = 0
    private var isAnimationActive            = true
    private var asset:AVURLAsset!
    
    private var playerItem: AVPlayerItem!
    private var assetGenerator:AVAssetImageGenerator!
    private var playerLayer: AVPlayerLayer!
    private var getCurrentTime:Double   = 0
    
    public init(videoURL:URL){
        super.init(nibName: nil, bundle: nil)
        
        self.videoURL   = videoURL
        
        asset       = AVURLAsset(url: videoURL)
        playerItem  = AVPlayerItem(asset: asset)
        player      = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        
        
        assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.maximumSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: playerVC.view.frame.height/3 * UIScreen.main.scale)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func presentAVPlayer(){
        player                                      = AVPlayer(url:videoURL)
        playerVC.player                             = player
        playerVC.showsPlaybackControls              = false
        asset                                       = AVURLAsset(url:videoURL)
        
        if subtitleResourceName != "" {
            let subTitle        = KoustSubTitleController(delegate: self)
            subTitle.setSubtitle(forResource: subtitleResourceName)
            //        subTitle.setSubtitleLink(srtUrl: "http://mmoplay2.org/Narcos.Mexico.S01E01.srt")
        }
        
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
        
        self.rewindBtn.addTarget(self, action: #selector(rewindBtnAction), for: .touchUpInside)
        
        self.rewindBtn.leftAnchor.constraint(equalTo: self.playAndPauseBtn.rightAnchor, constant:   35).isActive           = true
        self.rewindBtn.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: -15).isActive           = true
        self.rewindBtn.widthAnchor.constraint(equalToConstant: 25).isActive                                                = true
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
        
        self.createThumbView()
        self.subtitleView()
    }
    
    @objc private func rewindBtnAction(){
        
        if getCurrentTime-Double(rewindDuration) < 0 {
            self.setDuration(duration:0)
        }else{
            self.setDuration(duration:getCurrentTime-Double(rewindDuration))
        }
    }
    
    // handle tap for player view
    @objc private func mainHandleTap(){
        self.animationCount     =  0
        allViewShow()
    }
    
    private func allViewShow(){
        let alphaValue:CGFloat          =  1
        self.subtitleNotSliderBottomCons.isActive    = false
        self.subtitleBottomCons.isActive             = true
        
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.slider.alpha           = alphaValue
            self.remainingTime.alpha    = alphaValue
            self.playAndPauseBtn.alpha  = alphaValue
            self.rewindBtn.alpha        = alphaValue
            self.backButton.alpha       = alphaValue
        }, completion: { _ in
            self.isAnimationActive          = true
        })
    }
    

    @objc func playAndPauseBtnAction(){
            // vibration effect like netflix
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
            self.playState()
    }
    
    @objc func sliderValueChanged(_ sender:UISlider){
        self.pause()
        self.subtitle.isHidden          = true
        self.slider.maximumValue        = Float(self.playerVC.player?.currentItem?.duration.seconds ?? 0)
        let seconds : Float64           = Double(sender.value)
        
        
        
        self.thumbView.isHidden         = false
        self.thumbView.alpha            = 1
        if (self.slider.frame.size.width/2) >= (self.slider.frame.size.width*CGFloat((sender.value)/self.slider.maximumValue)) {
            self.thumbCenterXCons.constant  = -CGFloat(self.slider.frame.size.width/2) + (self.slider.frame.size.width*CGFloat((sender.value)/self.slider.maximumValue))
        }else{
            self.thumbCenterXCons.constant  = ((self.slider.frame.size.width)*(CGFloat((sender.value)/self.slider.maximumValue))) - (self.slider.frame.size.width/2)
        }
        self.playerVC.view.layoutIfNeeded()
        
        let playbackLikelyToKeepUp = self.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp
        if playbackLikelyToKeepUp == false{
            showActivityIndicatory(uiView: self.playerVC.view)
        }else{
            self.removeIndicatory()
        }
        
        
        hmsFrom(seconds: (Int(seconds))) { hours, minutes, seconds in
            
            let hours   = getStringFrom(seconds: hours)
            let minutes = getStringFrom(seconds: minutes)
            let seconds = getStringFrom(seconds: seconds)
            if hours == "00"{
                self.thumbCurrent.text   = "\(minutes):\(seconds)"
            }else{
                self.thumbCurrent.text  = "\(hours):\(minutes):\(seconds)"
            }
        }
        
        self.getThumbImage(sliderCurrentTime: Double(sender.value) ,handler: { image in
            DispatchQueue.main.async {
                
                self.thumbImage.image = image
                
            }
        })
 
    }
    
    @objc func sliderTouchUpInside(_ sender: UISlider){
        self.animationCount              =  0
        let newCurrentTime: TimeInterval = Double(sender.value)
        let seekToTime: CMTime           = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 100)


        
        self.playerVC.player?.seek(to: seekToTime)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.thumbView.alpha      = 0
        }, completion: { _ in
            self.thumbView.isHidden   = true
        })
        
        
        if newCurrentTime > (skipButtonDuration ?? 0 ) {
            self.skipBtnAnimationHide()
        }else{
            self.skipBtnAnimationShow()
        }
        self.indexOfSubtitle(currentTime: Double(sender.value))
        self.play()
    }
    
    
    
    @objc func sliderTouchUpOutside(_ sender:UISlider){
        let newCurrentTime: TimeInterval = Double(sender.value)
        let seekToTime: CMTime           = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 100)
        
        
        self.playerVC.player?.seek(to: seekToTime)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.thumbView.alpha      = 0
        }, completion: { _ in
            self.thumbView.isHidden   = true
        })
        
        
        if newCurrentTime > (skipButtonDuration ?? 0 ) {
            self.skipBtnAnimationHide()
        }else{
            self.skipBtnAnimationShow()
        }
        
        self.indexOfSubtitle(currentTime: Double(sender.value))
        self.play()
    }
    
    
    @objc func setSkipDuration(){
        self.setDuration(duration: self.skipButtonDuration!)
    }
    
    
    private func setDuration(duration:Double){
        self.pause()
        
        let newCurrentTime: TimeInterval = duration
        let seekToTime: CMTime           = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 100)
        
        self.slider.value                       = Float(seekToTime.seconds)
        self.slider.maximumValue                = Float(self.playerVC.player?.currentItem?.duration.seconds ?? 0)
        
        self.playerVC.player?.seek(to: seekToTime)
        self.subtitle.text   = ""
        self.indexOfSubtitle(currentTime: duration)
        
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
        
        self.play()
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.skipBtn.alpha      = 0
        }, completion: { _ in
            self.skipBtn.isHidden   = true
        })
    }
    
    

    @objc private func backButtonAction(){
        self.pause()
        player?.removeTimeObserver(observer ?? (Any).self)
        observer = nil
        
            
        self.playerVC.dismiss(animated: true, completion: nil)
        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
        
    }
    
    // Skip Button Animation Show Function
    private func skipBtnAnimationShow(){
        UIView.animate(withDuration: 0.5, delay: 0.15, options: [], animations: {
        self.skipBtn.alpha      = 0.6
        }, completion: { _ in
            self.skipBtn.isHidden   = false
        })
    }
    
    // Skip Button Animation Hide Function
    private func skipBtnAnimationHide(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.skipBtn.alpha      = 0
        }, completion: { _ in
            self.skipBtn.isHidden   = true
        })
    }
    
    // Thumbnail View
    private func createThumbView(currentThumbImage:UIImage = UIImage(),currentTime:String = ""){
        self.thumbView.backgroundColor                              = UIColor.black
        self.thumbView.alpha                                        = 1
        self.thumbView.isHidden                                     = true
        self.playerVC.view.addSubview(thumbView)
        
        
        self.thumbView.translatesAutoresizingMaskIntoConstraints    = false
        
        self.thumbCenterXCons = self.thumbView.centerXAnchor.constraint(equalTo: self.slider.centerXAnchor, constant: 0)
        
        self.thumbCenterXCons.isActive      = true
        
        self.thumbView.centerYAnchor.constraint(equalTo: self.playerVC.view.centerYAnchor, constant: 20).isActive   = true
        self.thumbView.widthAnchor.constraint(equalToConstant: self.playerVC.view.frame.width / 3).isActive         = true
        self.thumbView.heightAnchor.constraint(equalToConstant: self.playerVC.view.frame.height / 3).isActive       = true
        
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
    
    // It's show first start state of video
    private func playState(){
        switch autoPlay {
        case .play:
            self.play()
        case .pause:
            self.pause()
        }
        
        self.preriodicTimeObsever()
    }
    
    // Video Play Function
    func play(){
        self.playerVC.player?.play()
        self.playAndPauseBtn.setImage(imageNamed("pause-button"), for: .normal)
        self.autoPlay   = .pause
    }
    
    
    // Video Pause Function
    func pause(){
        self.playerVC.player?.pause()
        self.playAndPauseBtn.setImage(imageNamed("play-button"), for: .normal)
        self.autoPlay   = .play
    }
    
    private func getThumbImage(sliderCurrentTime:Double,handler:@escaping ((UIImage)->Void))  {
        
        guard let player = player ,
            let asset = player.currentItem?.asset else {
                return
        }
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let times = [NSValue(time: CMTime(seconds: sliderCurrentTime, preferredTimescale: 100))]
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: times) { _, image, _, _, _ in
            if image != nil {
                handler(UIImage(cgImage: image!))
            }
        }
 
        

    }
        
    
    

    
    // Subitle Protocol
    public func subtitleList(list: [SubtitleModel]) {
        self.subtitleList = list
    }
    
    private func indexOfSubtitle(currentTime:Double){
        
        let _ = self.subtitleList.enumerated().map{ (index,subModel) in
        
        if (self.subtitleList.first?.startToTime ?? 0) > currentTime {
            self.subtitleCount = 0
            self.subtitleState = .starToTime
        }else{
            
            if (subModel.startToTime ?? 0) <= currentTime {
                if (subModel.endToTime ?? 0) >= currentTime {
                    self.subtitleCount = index
                    self.subtitleState = .starToTime
                }
            }
        }

        }
    }
    
    // It's show subtitle.
    private func showSubtitle(currentTime:Double){
        
        // beginning
        if self.subtitleList.count > 0  && self.subtitleCount < self.subtitleList.count {
            
            // Start Subtitle
            if subtitleState == .starToTime {
                if (self.subtitleList[self.subtitleCount].startToTime ?? 0) <= currentTime {
                    self.subtitle.text                          = self.subtitleList[self.subtitleCount].text
                    self.subtitle.isHidden                      = false
                    self.subtitleState                          = .endToTime
                }
            }
            
            
            // End Subtitle
            if subtitleState == .endToTime {
                if (self.subtitleList[self.subtitleCount].endToTime ?? 0) <= currentTime {
                    self.subtitle.isHidden                      = true
                    if self.subtitleCount < self.subtitleList.count {
                        self.subtitleState   = .starToTime
                        self.subtitleCount += 1
                    }
                }
            }
            
        }
        // end
        
    }
    
    func preriodicTimeObsever(){
        
        if observer != nil {
            player?.removeTimeObserver(observer ?? (Any).self)
            observer = nil
        }
        
        observer = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: DispatchQueue.main) {
            [weak self] time in
            
            
            // Activity Indicator part
            let playbackLikelyToKeepUp = self?.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false{
                showActivityIndicatory(uiView: (self?.playerVC.view)!)
            }else{
                self?.removeIndicatory()

            }
            self?.showSubtitle(currentTime: time.seconds)
          
            
            let timeString = String(format: "%02.2f", CMTimeGetSeconds(time))
            
            if timeString != "0.00" {
                if let totalDuration =  self?.playerVC.player?.currentItem?.duration.seconds {
                    
                    self?.slider.maximumValue                = Float(totalDuration)
                    
                    self?.slider.setValue((Float(CMTimeGetSeconds(time))), animated: true)
                    
                    if CMTimeGetSeconds(time) > (self?.skipButtonDuration ?? 0) {
                        self?.skipBtnAnimationHide()
                    }else{
                        self?.skipBtnAnimationShow()
                    }
                    
                    //get current time
                    
                    self?.getCurrentTime = time.seconds
                    
                    // It's provide show total duration
                    hmsFrom(seconds: Int(totalDuration - CMTimeGetSeconds(time))){ hours, minutes, seconds in
                        let hours   = getStringFrom(seconds: hours)
                        let minutes = getStringFrom(seconds: minutes)
                        let seconds = getStringFrom(seconds: seconds)
                        if hours == "00"{
                            self?.remainingTime.text = "\(minutes):\(seconds)"
                        }else{
                            self?.remainingTime.text = "\(hours):\(minutes):\(seconds)"
                        }
                    }
                    
                    
                    self?.delegate?.koustPlayerPlaybackstimer(NSString: timeString)
                    
                    // works when video ends
                    if Float(totalDuration) == Float(CMTimeGetSeconds(time)) {
                        self?.pause()
                        self?.delegate?.koustPlayerPlaybackDidEnd()
                        self?.allViewShow()
                        switch self?.didEndState {
                        case .autoClose?:
                                self?.backButtonAction()
                        case .manualClose?:
                                break
                        case .none:
                            break
                        }
                    }
                    
                    
                    // We hiding all views
                    if self?.animationDuration == ((self?.animationCount)! / 100) && (self?.isAnimationActive)! {
                        self?.subtitleNotSliderBottomCons.isActive    = true
                        self?.subtitleBottomCons.isActive             = false
                        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                            self?.slider.alpha           = 0
                            self?.remainingTime.alpha    = 0
                            self?.playAndPauseBtn.alpha  = 0
                            self?.rewindBtn.alpha        = 0
                            self?.backButton.alpha       = 0
                        }, completion: { _ in
                            
                            self?.isAnimationActive                       = false
                        })
                    }
                    
                    self?.animationCount += 1
                }
            }
            
         
        }
    }
    
}


extension KoustPlayerView {
    
    // it's delete indicator
    private func removeIndicatory(){
        if let activityIndicatory = self.playerVC.view.viewWithTag(90) {
            activityIndicatory.removeFromSuperview()
        }
    }
    
    
}

    // View Part
extension KoustPlayerView {
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
    
    private func subtitleView(){
        self.subtitle.translatesAutoresizingMaskIntoConstraints     = false
        self.subtitle.backgroundColor                               = UIColor.black.withAlphaComponent(0.7)
        self.subtitle.textColor                                     = UIColor.white
        self.subtitle.layer.cornerRadius                            = 5
        self.subtitle.textAlignment                                 = .center
        self.subtitle.font                                          = UIFont(name: "AmericanTypewriter", size: 15)
        self.subtitle.isHidden                                      = true
        self.subtitle.numberOfLines                                 = 0
        self.subtitle.clipsToBounds                                 = true
        self.subtitle.lineBreakMode                                 = .byWordWrapping
        
        self.playerVC.view.addSubview(self.subtitle)
        
        self.subtitle.widthAnchor.constraint(lessThanOrEqualToConstant: 380).isActive                                   = true
        self.subtitle.centerXAnchor.constraint(equalTo: self.playerVC.view.centerXAnchor, constant: 0).isActive         = true
        self.subtitle.heightAnchor.constraint(greaterThanOrEqualToConstant: 25).isActive                                = true
        
        self.subtitleBottomCons             = self.subtitle.bottomAnchor.constraint(equalTo: self.slider.topAnchor, constant: -25)
        self.subtitleNotSliderBottomCons    = self.subtitle.bottomAnchor.constraint(equalTo: self.playerVC.view.bottomAnchor, constant: -15)
        
        self.subtitleNotSliderBottomCons.isActive    = false
        self.subtitleBottomCons.isActive             = true
    }
    
}
