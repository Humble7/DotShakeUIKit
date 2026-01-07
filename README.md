# DotShakeUIKit

A comprehensive iOS UIKit framework providing reusable UI components, rotatable knob controls, and an advanced glass-style floating toolbar system.

## Overview

DotShakeUIKit is a Swift Package that provides three libraries:

| Library | Description |
|---------|-------------|
| **DotShakeUIKit** | Core UI utilities and components (re-exports DotShakeKnob and DotShakeToolbar) |
| **DotShakeKnob** | Rotatable knob/dial control with marker support and haptic feedback |
| **DotShakeToolbar** | Glass-style floating toolbar with responsive layout system |

## Requirements

- iOS 17.0+
- Swift 6.1+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Humble7/DotShakeUIKit.git", from: "1.0.0")
]
```

Then add the products to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        // Option 1: Import all libraries at once
        .product(name: "DotShakeUIKit", package: "DotShakeUIKit"),

        // Option 2: Import individual libraries
        .product(name: "DotShakeKnob", package: "DotShakeUIKit"),
        .product(name: "DotShakeToolbar", package: "DotShakeUIKit"),
    ]
)
```

## DotShakeUIKit (Core Module)

The core module provides reusable UIKit utilities and re-exports both DotShakeKnob and DotShakeToolbar.

### UIFeedbackManager

Centralized feedback UI management for loading indicators and alerts.

```swift
// Show/hide loading indicator
UIFeedbackManager.shared.loading.show()
UIFeedbackManager.shared.loading.show(text: "Loading...")
UIFeedbackManager.shared.loading.update(text: "Processing...")
UIFeedbackManager.shared.loading.hide()

// Show alert dialog
UIFeedbackManager.shared.alert.show(
    title: "Error",
    message: "Something went wrong",
    confirmTitle: "OK",
    cancelTitle: "Cancel",
    onConfirm: { print("Confirmed") },
    onCancel: { print("Cancelled") }
)
```

### Base Classes for Programmatic UI

**NiblessViewController** - Base class that prevents XIB/Storyboard initialization:

```swift
class MyViewController: NiblessViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup UI programmatically
    }
}
```

**NiblessView** - Base class for programmatic views:

```swift
class MyCustomView: NiblessView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Setup subviews
    }
}
```

### UIViewController Extensions

```swift
// Find the topmost presented view controller
let topVC = viewController.topViewController()

// Child view controller management
parentVC.addFullScreen(childViewController: childVC)
parentVC.add(childViewController: childVC) { childView in
    // Custom constraints
}
parentVC.remove(childViewController: childVC)

// Present share sheet
viewController.presentActivityVC(with: [shareItems])

// Present error (requires FoundationKit.ErrorMessage)
viewController.present(errorMessage: error)
```

### SwipeDetectingButton

A UIButton that distinguishes between tap and swipe gestures:

```swift
let button = SwipeDetectingButton()
button.swipeThreshold = 30 // minimum distance to trigger swipe (default: 30)

button.onTap = {
    print("Tapped")
}

button.onSwipe = {
    print("Swiped")
}
```

### TransparentPassthroughView

A view that passes touches through to subviews only:

```swift
let overlay = TransparentPassthroughView()
overlay.isPassthroughEnabled = true  // touches pass through, only subviews receive touches
```

---

## DotShakeKnob

A feature-rich rotatable knob/dial control with visual markers, haptic feedback, and persistence support.

### Basic Knob

```swift
let knob = Knob()

// Value range
knob.minimumValue = 0
knob.maximumValue = 100

// Continuous updates during gesture
knob.isContinuous = true

// Set value
knob.setValue(50, animated: true)

// Listen for changes
knob.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
knob.addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
```

### Styling

```swift
// Track style (the circular arc)
knob.trackStyle = .drawing(lineWidth: 2, color: .systemGray)
// Or use an image
knob.trackStyle = .image(trackImage, contentMode: .scaleAspectFit)

// Pointer style (the indicator)
knob.pointerStyle = .drawing(length: 12, lineWidth: 2, color: .systemBlue)
// Or use an image
knob.pointerStyle = .image(pointerImage, size: CGSize(width: 20, height: 20))

// Angular range (in radians)
knob.startAngle = -.pi * 11/8  // default
knob.endAngle = .pi * 3/8      // default
```

### Haptic Feedback

```swift
// Feedback styles: .none, .step, .boundary, .stepAndBoundary
knob.hapticStyle = .stepAndBoundary

// Step feedback triggers every stepInterval
knob.stepInterval = 10
knob.stepFeedbackIntensity = 0.4  // 0.0 - 1.0

// Boundary feedback when hitting min/max
knob.boundaryFeedbackIntensity = 0.7
```

### MarkedKnob (Knob with Visual Markers)

```swift
let markedKnob = MarkedKnob()

// Access the underlying knob
markedKnob.minimumValue = 0
markedKnob.maximumValue = 100

// Add markers
markedKnob.addMarkerAtCurrentPosition()
markedKnob.addMarker(at: 25, color: .red, length: 10, lineWidth: 2)
markedKnob.addMarker(at: 50)  // uses markerStyle defaults

// Remove markers
markedKnob.removeMarker(at: 0)  // by index
markedKnob.removeAllMarkers()

// Marker style (defaults for new markers)
markedKnob.markerStyle = MarkerStyle(
    color: .systemRed,
    length: 15,
    lineWidth: 2,
    tolerance: 0.02  // how close to marker to detect
)

// Snap behavior
markedKnob.snapBehavior = SnapBehavior(
    enabled: true,
    threshold: 0.05,  // snap distance
    animated: true
)
// Or use presets
markedKnob.snapBehavior = .default
markedKnob.snapBehavior = .disabled

// Center symbol style (+/- indicator)
markedKnob.symbolStyle = SymbolStyle(
    color: .systemBlue,
    activeColor: .systemRed,
    size: 20,
    lineWidth: 2,
    tapRadius: 22
)

// Listen for marker changes
markedKnob.onMarkersChanged = { markers in
    print("Markers: \(markers.count)")
}
```

### Marker Persistence

```swift
// Save/load markers manually
Task {
    await MarkerStorage.shared.save(markers, forKey: "myKnob")
    let loaded = await MarkerStorage.shared.load(forKey: "myKnob")
    await MarkerStorage.shared.clear(forKey: "myKnob")
}

// Auto-binding (automatically saves/loads markers)
let binding = markedKnob.bindStorage(key: "myKnob")
// Later: binding.unbind() or await binding.clear()
```

---

## DotShakeToolbar

An advanced floating toolbar system with glass morphism design, responsive layout, and accessory views.

### Basic Setup

```swift
let toolbar = GlassToolbarController(configuration: .default)

// Define items
let items = [
    GlassToolbarItem(
        title: "Home",
        icon: UIImage(systemName: "house.fill"),
        isSelectable: true,
        action: { print("Home tapped") }
    ),
    GlassToolbarItem(
        title: "Search",
        icon: UIImage(systemName: "magnifyingglass"),
        isSelectable: true
    ),
    GlassToolbarItem(
        title: "Settings",
        icon: UIImage(systemName: "gear"),
        isSelectable: true
    )
]

toolbar.setItems(items)

// Selection callback
toolbar.onItemSelected = { index in
    print("Selected: \(index)")
}

// Add to parent view controller
addChild(toolbar)
view.addSubview(toolbar.view)
toolbar.didMove(toParent: self)
// Setup constraints...
```

### Configuration Presets

```swift
// Standard (56pt toolbar height)
let toolbar = GlassToolbarController(configuration: .default)

// Compact for smaller screens (48pt)
let compactToolbar = GlassToolbarController(configuration: .compact)

// Spacious for iPad (64pt)
let iPadToolbar = GlassToolbarController(configuration: .spacious)
```

### Item Priority System

Items can be assigned priorities that determine their behavior during layout compression:

```swift
GlassToolbarItem(
    title: "Primary",
    icon: icon,
    isSelectable: true,
    priority: .essential,    // Always visible, never hidden
    // priority: .primary,   // Shown preferentially (default)
    // priority: .secondary, // Hidden first when space is limited
    // priority: .overflow,  // Always in overflow menu
    compactTitle: "Pri",     // Short title for compressed layouts
    canHideTitle: true       // Allow title hiding when compressed
)
```

### Side Button

```swift
// Global side button (used for all items without their own)
toolbar.globalSideButton = GlassSideButtonConfig(
    icon: UIImage(systemName: "plus"),
    backgroundColor: .systemBlue,
    tintColor: .white,
    priority: .primary,      // .essential, .primary, .secondary
    overflowTitle: "Add",    // Title shown in overflow menu
    action: { print("Add") }
)

// Per-item side button (overrides global)
GlassToolbarItem(
    title: "Photos",
    icon: UIImage(systemName: "photo"),
    sideButton: GlassSideButtonConfig(
        icon: UIImage(systemName: "camera"),
        backgroundColor: .systemGreen,
        gestures: SideButtonGestureConfig(
            onTap: { print("Camera") },
            onSwipe: { direction in
                switch direction {
                case .up: print("Swipe up")
                case .down: print("Swipe down")
                case .left: print("Swipe left")
                case .right: print("Swipe right")
                }
            },
            enabledDirections: [.up, .down],
            swipeThreshold: 30,
            swipeVelocityThreshold: 200
        )
    )
)

// Update side button dynamically
toolbar.updateSideButtonAppearance(
    icon: UIImage(systemName: "checkmark"),
    backgroundColor: .systemGreen,
    tintColor: .white,
    animated: true
)
```

### Accessory Views

Accessory views appear below the toolbar when an item is selected:

```swift
// Create accessory from any UIView
let myView = UIView()
let accessory = myView.asAccessoryProvider(height: 60, width: nil)

// Or use SimpleAccessoryWrapper for more control
let wrapper = SimpleAccessoryWrapper(
    view: myView,
    preferredHeight: 60,
    preferredWidth: nil,    // nil = fill available width
    minimumWidth: 200,
    cleanup: { /* cleanup code */ }
)

// Attach to item
GlassToolbarItem(
    title: "Music",
    icon: UIImage(systemName: "music.note"),
    accessoryProvider: primaryAccessory,
    secondaryAccessoryProvider: secondaryAccessory  // optional second accessory
)

// Global accessory (fallback for items without one)
toolbar.globalAccessoryProvider = defaultAccessory
```

### HorizontalListAccessoryView (Built-in)

```swift
let listView = HorizontalListAccessoryView()

let items = [
    HorizontalListAccessoryView.ListItem(
        icon: UIImage(systemName: "folder"),
        title: "Documents",
        tintColor: .systemBlue
    ),
    HorizontalListAccessoryView.ListItem(
        icon: UIImage(systemName: "photo"),
        title: "Photos",
        tintColor: .systemGreen
    )
]

listView.configure(
    title: "Categories",
    items: items,
    selectedIndex: 0,
    configuration: .init(
        showsSelection: true,
        showsCount: true,
        selectionColor: .systemBlue,
        borderColor: nil  // defaults to selectionColor
    )
)

listView.onItemTap = { index in
    print("Selected: \(index)")
}

// Dynamic updates
listView.updateSelectionColor(.systemRed)
listView.updateBorderColor(.systemOrange)
```

### Custom Accessory Provider

Implement `GlassAccessoryProvider` for full control:

```swift
class MyAccessoryProvider: GlassAccessoryProvider {
    let accessoryView: UIView = MyCustomView()
    let preferredHeight: CGFloat = 80
    var preferredWidth: CGFloat? { nil }  // fill available
    var minimumWidth: CGFloat { 200 }

    func willAppear(animated: Bool) { /* prepare */ }
    func didAppear(animated: Bool) { /* shown */ }
    func willDisappear(animated: Bool) { /* hiding */ }
    func didDisappear(animated: Bool) { /* hidden */ }
    func cleanup() { /* release resources */ }
}
```

### Ultra Minimal Mode

```swift
// Enable/disable
toolbar.setUltraMinimalMode(true, animated: true)
toolbar.toggleUltraMinimalMode(animated: true)

// Check state
if toolbar.isUltraMinimalMode {
    // In minimal mode
}
```

### Layout Monitoring

```swift
// Current space tier
switch toolbar.currentSpaceTier {
case .spacious: print("Full layout")      // >= 520pt
case .regular: print("Standard")          // 420-519pt
case .compact: print("Compact")           // 360-419pt
case .tight: print("Tight")               // 280-359pt
case .minimal: print("Ultra minimal")     // < 280pt
}

// Current compression level
switch toolbar.currentCompressionLevel {
case .full: print("Full display + title")
case .comfortable: print("Standard spacing")
case .compact: print("Compact spacing")
case .iconOnly: print("Icons only")
case .overflow: print("Items in overflow")
}

// Items in overflow menu
let hidden = toolbar.overflowItems
```

### Custom Appearance

```swift
var config = ToolbarAppearanceConfiguration.default

// Sizes
config.toolbarHeight = 60
config.floatingButtonSize = 48
config.itemIconSize = 24
config.itemFullSize = CGSize(width: 56, height: 48)
config.itemCompactSize = CGSize(width: 44, height: 48)

// Animation
config.animationDuration = 0.35
config.springDamping = 0.85
config.springVelocity = 0.5

// Visual effects
config.toolbarCornerRadius = nil  // nil = automatic (height / 2)
config.toolbarShadowRadius = 20
config.toolbarShadowOpacity = 0.18
config.accessoryCornerRadius = 20

// Glass effect
config.glossTopAlpha = 0.28
config.glossMiddleAlpha = 0.08
config.borderTopAlpha = 0.5
config.borderBottomAlpha = 0.15

let toolbar = GlassToolbarController(configuration: config)
```

---

## Architecture

```
DotShakeUIKit
├── DotShakeUIKit (Core)
│   ├── UIFeedbackManager (LoadingController, AlertController)
│   ├── NiblessViewController / NiblessView
│   ├── UIViewController Extensions
│   ├── SwipeDetectingButton
│   └── TransparentPassthroughView
│
├── DotShakeKnob
│   ├── Knob (UIControl)
│   ├── MarkedKnob (UIControl)
│   ├── RotationGestureRecognizer
│   ├── MarkerStorage (Actor)
│   └── MarkerBinding
│
└── DotShakeToolbar
    ├── GlassToolbarController
    ├── GlassToolbarItem
    ├── GlassSideButtonConfig / SideButtonGestureConfig
    ├── GlassAccessoryProvider Protocol
    ├── SimpleAccessoryWrapper
    ├── HorizontalListAccessoryView
    ├── ToolbarLayoutCoordinator
    └── ToolbarAppearanceConfiguration
```

## Thread Safety

- All public APIs are designed to be called from the main thread (`@MainActor`)
- `MarkerStorage` is implemented as an `Actor` for thread-safe persistence
- Configuration structs conform to `Sendable` for safe cross-thread usage

## Dependencies

- [FoundationKit](https://github.com/Humble7/FoundationKit) - For `ErrorMessage` type used in error presentation

## License

MIT License
