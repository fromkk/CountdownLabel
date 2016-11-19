//
//  CountdownLabel.swift
//  CountdownLabel
//
//  Created by Ueoka Kazuya on 2016/11/19.
//
//

import UIKit

public protocol TextCustomizable: class {
    var textColor: UIColor! { get set }
    var font: UIFont! { get set }
    var textAlignment: NSTextAlignment { get set }
}

extension UILabel: TextCustomizable {}

fileprivate enum CountdownConstants {
    static let defaultTextColor: UIColor = UIColor.black
    static let defaultTextAlignment: NSTextAlignment = NSTextAlignment.center
    static let defaultFont: UIFont = UIFont.boldSystemFont(ofSize: 44.0)
}

fileprivate final class WheelLabel: UIView, TextCustomizable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard self.bounds.size != self.label.frame.size else {
            return
        }
        self.label.frame = self.bounds
    }

    // initialize
    private var didSetup = false
    private func setup() {
        guard false == self.didSetup else {
            return
        }
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.addSubview(self.label)

        self.didSetup = true
    }

    private lazy var label: UILabel = {
        let label: UILabel = UILabel(frame: self.bounds)
        label.text = "0"
        label.backgroundColor = UIColor.clear
        return label
    }()

    private weak var copied: UILabel?

    private lazy var regexp: NSRegularExpression = try! NSRegularExpression(pattern: "^[0-9]{1}$", options: [])

    
    var textChangedCount: Int = 0
    private var _storedText: String = "0"
    var text: String {
        get {
            return self._storedText
        }
        set {
            let range: NSRange = NSRange(location: 0, length: newValue.characters.count)
            if 0 == self.regexp.numberOfMatches(in: newValue, options: [], range: range) {
                fatalError("number format is incorrect")
            }

            if newValue != self.text {
                self._storedText = newValue
                self.didChanged(text: newValue, animated: 0 != self.textChangedCount)
                self.textChangedCount += 1
            }
        }
    }

    private func didChanged(text: String, animated: Bool) {
        if let copied: UILabel = self.copied {
            copied.removeFromSuperview()
            self.copied = nil
        }

        if animated {
            // base
            let baseRect: CGRect = self.bounds

            // base.origin.y -= base.size.height
            var minusRect: CGRect = baseRect
            minusRect.origin.y -= baseRect.size.height

            // base.origin.y += base.size.height
            var plusRect: CGRect = baseRect
            plusRect.origin.y += baseRect.size.height

            let copy: UILabel = UILabel(frame: minusRect)
            copy.text = text
            copy.textColor = self.label.textColor
            copy.textAlignment = self.label.textAlignment
            copy.font = self.label.font
            copy.backgroundColor = UIColor.clear
            self.addSubview(copy)
            self.copied = copy

            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.label.frame = plusRect
                self?.copied?.frame = baseRect
            }) { [weak self] (completed: Bool) in
                self?.label.text = text
                self?.label.frame = baseRect
                self?.copied?.removeFromSuperview()
            }
        } else {
            self.label.text = text
        }
    }

    // text customizable
    var textColor: UIColor! {
        get {
            return self.label.textColor
        }
        set {
            self.label.textColor = newValue
            self.copied?.textColor = newValue
        }
    }

    var textAlignment: NSTextAlignment {
        get {
            return self.label.textAlignment
        }
        set {
            self.label.textAlignment = newValue
            self.copied?.textAlignment = newValue
        }
    }

    var font: UIFont! {
        get {
            return self.label.font
        }
        set {
            self.label.font = newValue
            self.copied?.font = newValue
        }
    }
}

@IBDesignable
final public class CountdownLabel: UIView, TextCustomizable {

    private var didSetup: Bool = false
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    private func setup() {
        guard self.didSetup == false else {
            return
        }

        self.addSubview(self.h1)
        self.addSubview(self.h2)
        self.addSubview(self.colon1)
        self.addSubview(self.m1)
        self.addSubview(self.m2)
        self.addSubview(self.colon2)
        self.addSubview(self.s1)
        self.addSubview(self.s2)

        self.text = "00:00:00"

        self.didSetup = true
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let views: [UIView] = [self.h1, self.h2, self.colon1, self.m1, self.m2, self.colon2, self.s1, self.s2]
        var origin: CGPoint = CGPoint.zero
        views.forEach { (view) in
            var size: CGSize = CGSize.zero
            if view is WheelLabel {
                size = self.numberSize
            } else if view is UILabel {
                size = self.colonSize
            }
            view.frame = CGRect(origin: origin, size: size)

            origin = CGPoint(x: origin.x + size.width, y: 0.0)
        }
    }

    private enum Constants {
        static let numberWidth: CGFloat = 32.0
        static let colonWidth: CGFloat = 24.0
        static let timeFormat: String = "^([0-9]{1})([0-9]{1}):([0-9]{1})([0-9]{1}):([0-9]{1})([0-9]{1})$"
    }

    private lazy var regexp: NSRegularExpression = try! NSRegularExpression(pattern: Constants.timeFormat, options: [NSRegularExpression.Options.caseInsensitive])

    @IBInspectable
    public var text: String = "00:00:00" {
        didSet {
            let range: NSRange = NSRange(location: 0, length: self.text.characters.count)
            let matches: [NSTextCheckingResult] = self.regexp.matches(in: self.text, options: [], range: range)
            guard let match: NSTextCheckingResult = matches.first else {
                fatalError("time(\(self.text)) is incorrect")
            }

            self.h1.text = (self.text as NSString).substring(with: match.rangeAt(1))
            self.h2.text = (self.text as NSString).substring(with: match.rangeAt(2))
            self.m1.text = (self.text as NSString).substring(with: match.rangeAt(3))
            self.m2.text = (self.text as NSString).substring(with: match.rangeAt(4))
            self.s1.text = (self.text as NSString).substring(with: match.rangeAt(5))
            self.s2.text = (self.text as NSString).substring(with: match.rangeAt(6))
            self.setNeedsDisplay()
        }
    }

    private var numberSize: CGSize {
        let totalWidth: CGFloat = Constants.numberWidth * 6 + Constants.colonWidth * 2
        let rate: CGFloat = Constants.numberWidth / totalWidth
        return CGSize(width: self.frame.size.width * rate, height: self.frame.size.height)
    }

    private var colonSize: CGSize {
        let totalWidth: CGFloat = Constants.numberWidth * 6 + Constants.colonWidth * 2
        let rate: CGFloat = Constants.colonWidth / totalWidth
        return CGSize(width: self.frame.size.width * rate, height: self.frame.size.height)
    }

    private lazy var labels: [TextCustomizable] = [self.h1, self.h2, self.colon1, self.m1, self.m2, self.colon2, self.s1, self.s2]

    @IBInspectable
    public var font: UIFont! = CountdownConstants.defaultFont {
        didSet {
            self.labels.forEach { $0.font = self.font }
        }
    }

    // text customizable
    @IBInspectable
    public var textAlignment: NSTextAlignment = CountdownConstants.defaultTextAlignment {
        didSet {
            self.labels.forEach { $0.textAlignment = self.textAlignment }
            self.setNeedsDisplay()
        }
    }

    @IBInspectable
    public var textColor: UIColor! = CountdownConstants.defaultTextColor {
        didSet {
            self.labels.forEach { $0.textColor = self.textColor }
            self.setNeedsDisplay()
        }
    }

    // wheel labels
    private lazy var h1: WheelLabel = {
        let label: WheelLabel = WheelLabel(frame: CGRect(origin: CGPoint.zero, size: self.numberSize))
        self.labelSetup(with: label)
        return label
    }()

    private lazy var h2: WheelLabel = {
        let label: WheelLabel = WheelLabel(frame: CGRect(origin: CGPoint.zero, size: self.numberSize))
        self.labelSetup(with: label)
        return label
    }()

    private lazy var colon1: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: self.colonSize))
        label.text = ":"
        self.labelSetup(with: label)
        return label
    }()

    private lazy var m1: WheelLabel = {
        let label: WheelLabel = WheelLabel(frame: CGRect(origin: CGPoint.zero, size: self.numberSize))
        self.labelSetup(with: label)
        return label
    }()

    private lazy var m2: WheelLabel = {
        let label: WheelLabel = WheelLabel(frame: CGRect(origin: CGPoint.zero, size: self.numberSize))
        self.labelSetup(with: label)
        return label
    }()

    private lazy var colon2: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: self.colonSize))
        label.text = ":"
        self.labelSetup(with: label)
        return label
    }()

    private lazy var s1: WheelLabel = {
        let label: WheelLabel = WheelLabel(frame: CGRect(origin: CGPoint.zero, size: self.numberSize))
        self.labelSetup(with: label)
        return label
    }()

    private lazy var s2: WheelLabel = {
        let label: WheelLabel = WheelLabel(frame: CGRect(origin: CGPoint.zero, size: self.numberSize))
        self.labelSetup(with: label)
        return label
    }()

    private func labelSetup(with label: TextCustomizable) {
        label.textAlignment = CountdownConstants.defaultTextAlignment
        label.textColor = CountdownConstants.defaultTextColor
        label.font = CountdownConstants.defaultFont
    }
}
