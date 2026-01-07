# DotShakeUIKit

<p align="center">
  <img src="Assets/0-app-screenShot.png" width="600" />
</p>



A comprehensive iOS UIKit framework featuring a rotatable knob control with haptic feedback and marker support, plus an adaptive glass-style floating toolbar with responsive layout system. Built for iOS 17+.

### Used By

<a href="https://apps.apple.com/au/app/dotshake/id6747894313">
  <img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us" alt="Download DotShake" height="40">
</a>

## Libraries

| Library | Description | Documentation |
|---------|-------------|---------------|
| **DotShakeUIKit** | Core UI utilities (re-exports Knob and Toolbar) | - |
| **DotShakeKnob** | Rotatable knob with markers, haptics, and persistence | [Docs](Docs/DotShakeKnob.md) |
| **DotShakeToolbar** | Glass-style adaptive toolbar with accessory views | [Docs](Docs/DotShakeToolbar.md) |

## Requirements

- iOS 17.0+
- Swift 6.1+
- Xcode 16.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Humble7/DotShakeUIKit", from: "0.0.2")
]
```

```swift
// Import all libraries
.product(name: "DotShakeUIKit", package: "DotShakeUIKit")

// Or import individually
.product(name: "DotShakeKnob", package: "DotShakeUIKit")
.product(name: "DotShakeToolbar", package: "DotShakeUIKit")
```

## Showcase

Apps using DotShakeToolbar in production:

| App | Description |
|-----|-------------|
| [DotShake](https://apps.apple.com/au/app/dotshake/id6747894313) | A delightful drawing app for iOS |

> Using DotShakeUIKit in your app? Feel free to open a PR to add it here!

## Quick Start

### DotShakeKnob

```swift
import DotShakeKnob

let knob = MarkedKnob()
knob.trackStyle = .drawing(lineWidth: 4, color: .systemGray3)
knob.pointerStyle = .drawing(length: 14, lineWidth: 4, color: .systemBlue)
knob.hapticStyle = .stepAndBoundary

// Add markers and enable snap
knob.addMarker(at: 0.5)
knob.snapBehavior = .default

// Auto-persist markers
let binding = knob.bindStorage(key: "myKnob")
```

### DotShakeToolbar

```swift
import DotShakeToolbar

let toolbar = GlassToolbarController(configuration: .default)

toolbar.setItems([
    GlassToolbarItem(
        title: "Home",
        icon: UIImage(systemName: "house.fill"),
        isSelectable: true,
        sideButton: .addButton { print("Add") },
        accessoryProvider: myAccessoryView
    ),
    GlassToolbarItem(
        title: "Settings",
        icon: UIImage(systemName: "gear"),
        isSelectable: true
    )
])

toolbar.onItemSelected = { index in
    print("Selected: \(index)")
}

// Add to parent
addChild(toolbar)
view.addSubview(toolbar.view)
toolbar.didMove(toParent: self)
```

### DotShakeUIKit (Core)

```swift
import DotShakeUIKit

// Loading indicator
UIFeedbackManager.shared.loading.show(text: "Loading...")
UIFeedbackManager.shared.loading.hide()

// Alert
UIFeedbackManager.shared.alert.show(title: "Error", message: "Something went wrong")

// Programmatic view controllers
class MyVC: NiblessViewController { }
class MyView: NiblessView { }
```

## Documentation

For detailed API documentation and usage examples:

- **[DotShakeKnob Documentation](Docs/DotShakeKnob.md)** - Knob control, markers, haptics, persistence
- **[DotShakeToolbar Documentation](Docs/DotShakeToolbar.md)** - Toolbar, side buttons, accessory views, layout system

## License

MIT License
