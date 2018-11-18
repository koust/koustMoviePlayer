//
//  KoustSubTitleController.swift
//  koustMoviePlayer
//
//  Created by Batuhan Saygili on 13.11.2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import Foundation

public class KoustSubTitleController {

    public var delegate:KoustSubtitleDelegate
    fileprivate var subtitleModel:[SubtitleModel]   = []
    
    
    private var hour: TimeInterval   = 0.0
    private var minute: TimeInterval = 0.0
    private var second: TimeInterval = 0.0
    private var c: TimeInterval      = 0.0
    
    init(delegate:KoustSubtitleDelegate){
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setSubtitle(forResource:String){
        let subtitleFile = Bundle.main.path(forResource: forResource, ofType: "srt")
        let subtitleURL  = URL(fileURLWithPath: subtitleFile!)
        
        
        self.readingStrFile(subtitleURL: subtitleURL)
    }

    private func payLoad(text:String) -> String{
        
        var payload = text.replacingOccurrences(of: "\n\r\n", with: "\n\n")
        payload     = payload.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        payload     = payload.replacingOccurrences(of: "\r\n", with: "\n")
        
        return payload
    }
    
    private func getFromTime(fromTime:String) -> Double {
        
        let scanner = Scanner(string: fromTime)
        
        scanner.scanDouble(&hour)
        scanner.scanString(":", into: nil)
        scanner.scanDouble(&minute)
        scanner.scanString(":", into: nil)
        scanner.scanDouble(&second)
        scanner.scanString(",", into: nil)
        scanner.scanDouble(&c)
        
        let fromTime = (hour * 3600.0) + (minute * 60.0) + second + (c / 1000.0)
        
        return fromTime
    }
    
    private func getToTime(toTime:String) -> Double {
        
        let scanner = Scanner(string: toTime)
        
        scanner.scanDouble(&hour)
        scanner.scanString(":", into: nil)
        scanner.scanDouble(&minute)
        scanner.scanString(":", into: nil)
        scanner.scanDouble(&second)
        scanner.scanString(",", into: nil)
        scanner.scanDouble(&c)
        
        let toTime = (hour * 3600.0) + (minute * 60.0) + second + (c / 1000.0)
        
        return toTime
    }
    
    // Reading File
    private func readingStrFile(subtitleURL:URL){
        do {
            let string = try! String(contentsOf: subtitleURL, encoding: .utf8)
            let payload = self.payLoad(text: string)
            
            let pattern = "(\\d+)\\n([\\d:,.]+)\\s+-{2}\\>\\s+([\\d:,.]+)\\n([\\s\\S]*?(?=\\n{2,}|$))"
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                let matches = regex.matches(in: payload,options: NSRegularExpression.MatchingOptions(rawValue: 0),  range: NSMakeRange(0, payload.count))
                for m in matches {
                    
                    let group = (payload as NSString).substring(with: m.range)
                    var regex = try NSRegularExpression(pattern: "^[0-9]+", options: .caseInsensitive)
                    var match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))

                    
                    regex = try NSRegularExpression(pattern: "\\d{1,2}:\\d{1,2}:\\d{1,2}[,.]\\d{1,3}", options: .caseInsensitive)
                    match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
                    
                    guard match.count == 2 else {
                        continue
                    }
                    guard let from = match.first, let to = match.last else {
                        continue
                    }
                
                    let fromStr = (group as NSString).substring(with: from.range)
                    let toStr   = (group as NSString).substring(with: to.range)
                    
                    let range = NSMakeRange(0, to.range.location + to.range.length + 1)
                    guard (group as NSString).length - range.length > 0 else {
                        continue
                    }
                    let text = (group as NSString).replacingCharacters(in: range, with: "")
                    
                    let subTitleModel               = SubtitleModel()
                    subTitleModel.index             = 0
                    subTitleModel.startToTime       = getFromTime(fromTime: fromStr)
                    subTitleModel.endToTime         = getToTime(toTime: toStr)
                    subTitleModel.text              = text
                    
                    self.subtitleModel.append(subTitleModel)
                    
                }
                self.delegate.subtitleList(list: self.subtitleModel)
            }catch {
                print("oops!! Error")
            }
        }
    }
    
    
    
    
}
