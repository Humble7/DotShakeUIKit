# DotShakeUIKit

A comprehensive iOS UIKit framework package providing reusable UI components and utilities for iOS 17+.

## Overview

DotShakeUIKit is a Swift Package that provides three distinct libraries:

- **DotShakeUIKit** - Core reusable UI utilities and components
- **DotShakeKnob** - Rotatable knob/dial control with marker support
- **DotShakeToolbar** - Advanced "Glass" style floating toolbar system

## Requirements

- iOS 17.0+
- Swift 6.1+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/DotShakeUIKit.git", from: "1.0.0")
]
```

Then add the desired products to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "DotShakeUIKit", package: "DotShakeUIKit"),
        .product(name: "DotShakeKnob", package: "DotShakeUIKit"),
        .product(name: "DotShakeToolbar", package: "DotShakeUIKit"),
    ]
)
```

## DotShakeUIKit (Core Module)

Provides reusable UIKit utilities and base components.

### UIFeedbackManager

Centralized feedback UI management with loading and alert controllers.

```swift
// Show loading indicator
UIFeedbackManager.shared.loading.show()
UIFeedbackManager.shared.loading.show(text: "Loading...")

// Hide loading indicator
UIFeedbackManager.shared.loading.hide()

// Show alert
UIFeedbackManager.shared.alert.show(
    title: "Error",
    message: "Something went wrong"
)
```

### Base Classes

**NiblessViewController** - Base class for programmatic view controllers:

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
// Find topmost view controller
let topVC = viewController.topViewController()

// Add child view controller (full screen)
parentVC.addFullScreen(childViewController: childVC)

// Remove child view controller
parentVC.remove(childViewController: childVC)

// Present share sheet
viewController.presentActivityVC(with: shareItems)

// Present error alert
viewController.present(errorMessage: error)
```

### SwipeDetectingButton

A UIButton subclass that distinguishes between tap and swipe gestures:

```swift
let button = SwipeDetectingButton()
button.swipeThreshold = 30 // minimum distance to trigger swipe

button.onTap = {
    print("Button tapped")
}

button.onSwipe = {
    print("Button swiped")
}
```

### TransparentPassthroughView

A UIView that can selectively pass touches through:

```swift
let overlayView = TransparentPassthroughView()
overlayView.isPassthroughEnabled = true // touches pass through to subviews only
```

## DotShakeKnob

A feature-rich rotatable knob/dial control with visual markers, haptic feedback, and snapping behavior.

### Basic Knob

```swift
let knob = Knob()
knob.minimumValue = 0
knob.maximumValue = 100
knob.isContinuous = true

// Styling
knob.trackStyle = .drawing(lineWidth: 2, color: .systemGray)
knob.pointerStyle = .drawing(length: 12, lineWidth: 2, color: .systemBlue)

// Or use images
knob.trackStyle = .image(trackImage, contentMode: .scaleAspectFit)
knob.pointerStyle = .image(pointerImage, size: CGSize(width: 20, height: 20))

// Haptic feedback
knob.hapticStyle = .stepAndBoundary
knob.stepInterval = 10
knob.stepFeedbackIntensity = 0.5
knob.boundaryFeedbackIntensity = 1.0

// Set value
knob.setValue(50, animated: true)

// Listen for changes
knob.addTarget(self, action: #selector(knobValueChanged), for: .valueChanged)
knob.addTarget(self, action: #selector(knobEditingEnded), for: .editingDidEnd)
```

### MarkedKnob (with Markers)

```swift
let markedKnob = MarkedKnob()

// Add markers
markedKnob.addMarker(at: 25, color: .red, length: 10, lineWidth: 2)
markedKnob.addMarker(at: 50, color: .green, length: 10, lineWidth: 2)
markedKnob.addMarkerAtCurrentPosition() // Add marker at current value

// Remove markers
markedKnob.removeMarker(at: 25)
markedKnob.removeAllMarkers()

// Snap behavior
markedKnob.snapBehavior = SnapBehavior(
    enabled: true,
    threshold: 5.0,
    animated: true
)

// Marker style
markedKnob.markerStyle = MarkerStyle(
    color: .systemOrange,
    length: 12,
    lineWidth: 2,
    tolerance: 0.5
)

// Listen for marker changes
markedKnob.onMarkersChanged = { markers in
    print("Markers updated: \(markers.count)")
}
```

### MarkerStorage (Persistence)

```swift
// Save markers
await MarkerStorage.shared.save(markers, forKey: "myKnob")

// Load markers
let markers = await MarkerStorage.shared.load(forKey: "myKnob")

// Clear saved markers
await MarkerStorage.shared.clear(forKey: "myKnob")
```

## DotShakeToolbar

An advanced floating toolbar system with glass morphism design, multiple display modes, and accessory views.

### Basic Setup

```swift
let toolbar = GlassToolbarController(configuration: .default)

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
toolbar.onItemSelected = { index in
    print("Selected: \(index)")
}

// Add to parent
addChild(toolbar)
view.addSubview(toolbar.view)
toolbar.didMove(toParent: self)
// Setup constraints...
```

### Configuration Presets

```swift
// Standard configuration (56pt toolbar height)
let toolbar = GlassToolbarController(configuration: .default)

// Compact for smaller screens (48pt toolbar)
let compactToolbar = GlassToolbarController(configuration: .compact)

// Spacious for iPad (64pt toolbar)
let iPadToolbar = GlassToolbarController(configuration: .spacious)
```

### Toolbar Items with Priority

```swift
GlassToolbarItem(
    title: "Primary",
    icon: icon,
    isSelectable: true,
    priority: .primary,      // Always visible
    compactTitle: "Pri",     // Short title for compressed layouts
    canHideTitle: true       // Allow title hiding when compressed
)
```

### Side Button

```swift
// Global side button for all items
toolbar.globalSideButton = GlassSideButtonConfig(
    icon: UIImage(systemName: "plus"),
    backgroundColor: .systemBlue,
    tintColor: .white,
    action: { print("Add tapped") }
)

// Per-item side button (overrides global)
GlassToolbarItem(
    title: "Photos",
    icon: UIImage(systemName: "photo"),
    sideButton: GlassSideButtonConfig(
        icon: UIImage(systemName: "camera"),
        backgroundColor: .systemGreen,
        gestures: SideButtonGestureConfig(
            onTap: { print("Camera tapped") },
            onSwipe: { direction in
                switch direction {
                case .up: print("Swipe up")
                case .down: print("Swipe down")
                case .left: print("Swipe left")
                case .right: print("Swipe right")
                }
            },
            enabledDirections: [.up, .down]
        )
    )
)

// Update side button dynamically
toolbar.updateSideButtonAppearance(
    icon: UIImage(systemName: "checkmark"),
    backgroundColor: .systemGreen,
    animated: true
)
```

### Accessory Views

```swift
// Simple accessory from any UIView
let myView = UIView()
let accessory = myView.asAccessoryProvider(preferredHeight: 60)

// Or use SimpleAccessoryWrapper
let accessory = SimpleAccessoryWrapper(
    view: myView,
    preferredHeight: 60,
    preferredWidth: nil,  // nil = fill available width
    minimumWidth: 200
)

// Attach to item
GlassToolbarItem(
    title: "Music",
    icon: UIImage(systemName: "music.note"),
    accessoryProvider: primaryAccessory,
    secondaryAccessoryProvider: secondaryAccessory  // Optional secondary
)

// Global accessory (fallback for items without one)
toolbar.globalAccessoryProvider = defaultAccessory
```

### HorizontalListAccessoryView (Built-in)

```swift
let listAccessory = HorizontalListAccessoryView()

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

listAccessory.configure(
    title: "Categories",
    items: items,
    selectedIndex: 0,
    configuration: .init(
        showsSelection: true,
        showsCount: true,
        selectionColor: .systemBlue
    )
)

listAccessory.onItemTap = { index in
    print("Selected category: \(index)")
}
```

### Ultra Minimal Mode

```swift
// Enable ultra minimal mode
toolbar.setUltraMinimalMode(true, animated: true)

// Toggle
toolbar.toggleUltraMinimalMode(animated: true)

// Check current state
if toolbar.isUltraMinimalMode {
    // Handle minimal mode
}
```

### Layout Monitoring

```swift
// Current layout tier
switch toolbar.currentSpaceTier {
case .spacious: print("Full layout")
case .regular: print("Standard layout")
case .compressed: print("Compressed layout")
case .tight: print("Minimal layout with overflow")
}

// Items in overflow menu
let overflowItems = toolbar.overflowItems
```

### Custom Appearance

```swift
var appearance = ToolbarAppearanceConfiguration.default

// Sizes
appearance.toolbarHeight = 60
appearance.floatingButtonSize = 48
appearance.itemIconSize = 24

// Animation
appearance.animationDuration = 0.3
appearance.springDamping = 0.8

// Visual effects
appearance.toolbarCornerRadius = 20
appearance.toolbarShadowRadius = 10
appearance.toolbarShadowOpacity = 0.15

let toolbar = GlassToolbarController(configuration: appearance)
```

## Architecture

```
DotShakeUIKit
├── DotShakeUIKit (Core)
│   ├── UIFeedbackManager
│   ├── NiblessViewController / NiblessView
│   ├── SwipeDetectingButton
│   └── TransparentPassthroughView
│
├── DotShakeKnob
│   ├── Knob (UIControl)
│   ├── MarkedKnob (UIControl)
│   ├── RotationGestureRecognizer
│   └── MarkerStorage (Actor)
│
└── DotShakeToolbar
    ├── GlassToolbarController
    ├── GlassToolbarItem / GlassSideButtonConfig
    ├── GlassAccessoryProvider Protocol
    ├── HorizontalListAccessoryView
    ├── ToolbarLayoutCoordinator
    └── ToolbarAppearanceConfiguration
```

## Thread Safety

- All public APIs are designed to be called from the main thread (`@MainActor`)
- `MarkerStorage` is implemented as an `Actor` for thread-safe persistence
- Configuration structs conform to `Sendable` for safe cross-thread usage

## License

MIT License
