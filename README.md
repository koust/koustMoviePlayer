![iOS 10.0+](https://img.shields.io/badge/iOS-10.0%2B-blue.svg)
![Swift 4.0+](https://img.shields.io/badge/Swift-4.0%2B-orange.svg)
![CocoaPods](https://img.shields.io/cocoapods/v/AFNetworking.svg)

# KoustMoviePlayer

KoustMoviePlayer is a custom player for iOS. It's similar to Netflix's Player and it is almost available with its all features.


## Preview [Movie]

[![KoustMoviePlayer](https://i.ytimg.com/vi/3ivGqio0b4w/hqdefault.jpg?sqp=-oaymwEZCNACELwBSFXyq4qpAwsIARUAAIhCGAFwAQ==&rs=AOn4CLAMM7zcScwhh5-N29OQHod-D8mpEQ)](https://youtu.be/3ivGqio0b4w "KoustMoviePlayer Youtube")

## Requirements

- iOS 10.0+
- Xcode 10.0
- Swift 4+

## Features
  - Skip Button (used for skip the any specific time that want to jump)
  - Rewind Button (used for rewind. If you want you can also set time.) 
  - Subtitle
  - Thumbnail Animation
  
  
## CocoaPods
   You can use [CocoaPods](http://cocoapods.org/) to install `koustMoviePlayer` by adding it to your `Podfile`:

   ```ruby
    platform :ios, '10.0'
    use_frameworks!
    pod 'koustMoviePlayer'
   ```

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
