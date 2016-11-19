# CountdownLabel

<img src="https://cloud.githubusercontent.com/assets/322930/20455353/2d164494-ae9d-11e6-9351-02415633e31e.gif" width="320" height="auto">

`CountdownLabel` is able to display countdown animation.

# Required

- **Xcode 8** or later
- **Swift 3.0.1 or later**
- **iOS 10** or later
- **Carthage** or **Cocoapods**

# Install

## Carthage

Add `github "fromkk/CountdownLabel"` to **Cartfile** and execute `carthage update` command on your terminal in project directory.  

Add **Carthage/Build/{Platform}/CountdownLabel.framework** to **Link Binary with Libralies** in you project.  
If you doesn't use Carthage, add **New Run Script Phase** and input `/usr/local/bin/carthage copy-frameworks` in **Build Phases** tab.  
Add `$(SRCROOT)/Carthage/Build/{Platform}/CountdownLabel.framework` to **Input Files**.

## with Cocoapods

Add `pod 'CountdownLabel'` to **Podfile** and run `pod install` command on your terminal in project directory.
Open `{YourProject}.xcworkspace` file.

# Usage

```swift
let countdownLabel: CountdownLabel = CountdownLabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 320.0, height: 80.0)))

let goal: Date = Date(timeIntervalSinceNow: 60 * 60 * 24)
let manager: CountdownManager = CountdownManager(with: goal)
manager.timerUpdate { (text: String) in
    countdownLabel.text = text
}
manager.activate()
```

## Customize

### CountdownLabel

```swift
countdownLabel.textColor = UIColor.blue
countdownLabel.font = UIFont.boldSystemFont(ofSize: 64.0)
```

### CountdownManager

```swift
manager.intervalPerSeconds = 12
manager.timerFinish {
    print("finished!!!")
}
```
