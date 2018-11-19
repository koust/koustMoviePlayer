# KoustMoviePlayer

KoustMoviePlayer is a custom player for iOS. It's similar to Netflix Player and Almost , available all features. 


## Preview [Movie]

[![KoustMoviePlayer](https://i.ytimg.com/vi/3ivGqio0b4w/hqdefault.jpg?sqp=-oaymwEZCNACELwBSFXyq4qpAwsIARUAAIhCGAFwAQ==&rs=AOn4CLAMM7zcScwhh5-N29OQHod-D8mpEQ)](https://youtu.be/3ivGqio0b4w "KoustMoviePlayer Youtube")

## Features
  - Skip Button (used to skip the trailer)
  - Rewind Button (used to rewind. If you want can be set time.)
  - Subtitle
  - Thumbnail Animation


## Manually
  1. Download and drop ```class``` path in your project.  
  2. Congratulations!  

## Usage

### Basic Usage


```swift    
    var koustMPC:KoustPlayerView!
    
    override func viewWillAppear(_ animated: Bool) {
        
       koustMPC = KoustPlayerView(videoURL:URL(string:"https://samplevideos.com/video123/mp4/720/big_buck_bunny_720p_10mb.mp4")!)
        
    }


    @IBAction func playAction(_ sender: Any) {
        
        koustMPC.subtitleResourceName = "sample"
        koustMPC.skipButtonDuration = 5
        koustMPC.skipButtonActive   = true
        koustMPC.backButtonTitle    = "Cartoon Movie | For Kids +4"
        koustMPC.autoPlay           = .play
        koustMPC.presentAVPlayer()
    }
    
```


### Subtitle (You can use the subtitle feature separately.)

  1. Download and drop ```SubtitleModel.swift,KoustSubtitleController.swift and KoustPlayerProtocol.swift```  in your project.
  2. ```swift
  
        let subTitle        = KoustSubTitleController(delegate: self)
        subTitle.setSubtitle(forResource: "exampleSrtFile")```
        
   3. You should be add ```KoustSubtitleDelegate``` class.
   4. Congratulations!  
