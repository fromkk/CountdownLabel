//
//  CountdownManager.swift
//  CountdownLabel
//
//  Created by Kazuya Ueoka on 2016/11/19.
//
//

import UIKit
import QuartzCore

public final class CountdownManager {
    private struct Time {
        static let seconds: Double = 1.0
        static let minutes: Double = seconds * 60.0
        static let hour: Double = minutes * 60.0
    }
    private enum Constants {
        static let maxHour: Int = 99
        static let defaultIntervalPerSeconds: Int = 4
    }
    
    public var goal: Date
    public typealias Update = (_ time: String) -> ()
    private var update: Update?
    
    public var intervalPerSeconds: Int = Constants.defaultIntervalPerSeconds
    
    public typealias Finish = () -> ()
    private var finish: Finish?
    
    public init(with goal: Date) {
        self.goal = goal
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive(notification:)), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillResignActive(notification:)), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    deinit {
        self.inactivate()
        self.update = nil
        self.finish = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    public func timerUpdate(_ update: @escaping Update) {
        self.update = update
    }
    
    public func timerFinish(_ finish: @escaping Finish) {
        self.finish = finish
    }
    
    private var displayLink: CADisplayLink?
    
    //MARK: actives
    public var isActive: Bool {
        return nil != self.displayLink
    }
    public func activate() {
        guard nil == self.displayLink else {
            return
        }
        guard Date().timeIntervalSince1970 < self.goal.timeIntervalSince1970 else {
            self.handleTimer()
            return
        }
        
        self.handleTimer()
        self.displayLink = CADisplayLink(target: self, selector: #selector(self.handleTimer))
        if #available(iOS 10.0, *) {
            self.displayLink?.preferredFramesPerSecond = self.intervalPerSeconds
        } else {
            self.displayLink?.frameInterval = 60 / self.intervalPerSeconds
        }
        self.displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    public func inactivate() {
        guard let displayLink = self.displayLink else {
            return
        }
        displayLink.invalidate()
        self.displayLink = nil
    }
    
    //MARK: handling text
    @objc func handleTimer() {
        DispatchQueue.main.async {
            let current: Date = Date()
            var diff: Double = self.goal.timeIntervalSince1970 - current.timeIntervalSince1970
            if diff <= 0.0 {
                self.inactivate()
                diff = 0.0
                self.finish?()
            }
            
            let hour: Int = Int(diff / Time.hour)
            let minute: Int = Int((diff - (Double(hour) * Time.hour)) / Time.minutes)
            let seconds: Int = Int(diff - (Double(hour) * Time.hour) - (Double(minute) * Time.minutes))
            
            self.update?(String(format: "%02d:%02d:%02d", Constants.maxHour < hour ? Constants.maxHour : hour, minute, seconds))
        }
    }
    
    //MARK: applicatio delegate
    var autoActivation: Bool = false
    @objc func applicationWillResignActive(notification: Notification) {
        self.autoActivation = self.isActive
        self.inactivate()
    }
    
    @objc func applicationDidBecomeActive(notification: Notification) {
        if self.autoActivation {
            self.activate()
        }
    }
}
