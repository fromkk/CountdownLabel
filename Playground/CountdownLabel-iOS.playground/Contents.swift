//: Playground - noun: a place where people can play

import UIKit
import CountdownLabel
import PlaygroundSupport

let countdownLabel: CountdownLabel = CountdownLabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 320.0, height: 80.0)))
countdownLabel.backgroundColor = UIColor.white
countdownLabel.textColor = UIColor.black
countdownLabel.text = "00:00:00"

let goal: Date = Date(timeIntervalSinceNow: 60 * 60)

let manager: CountdownManager = CountdownManager(with: goal)
manager.timerUpdate { (text: String) in
    countdownLabel.text = text
}
manager.activate()

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = countdownLabel
