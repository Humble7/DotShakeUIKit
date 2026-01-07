//
//  Knob.swift
//  DotShakeKnob
//
//  Created by ChenZhen on 4/1/26.
//

import UIKit

public enum HapticFeedbackStyle {
    case none
    case step
    case boundary
    case stepAndBoundary
}

public enum TrackStyle {
    case drawing(lineWidth: CGFloat = 2, color: UIColor = .systemBlue)
    case image(UIImage, contentMode: UIView.ContentMode = .scaleAspectFit)
}

public enum PointerStyle {
    case drawing(length: CGFloat = 6, lineWidth: CGFloat = 2, color: UIColor = .systemBlue)
    case image(UIImage, size: CGSize? = nil)
}

open class Knob: UIControl {

    public var minimumValue: CGFloat = 0.0

    public var maximumValue: CGFloat = 1.0

    public var startAngle: CGFloat {
        get { return renderer.startAngle }
        set { renderer.startAngle = newValue }
    }

    public var endAngle: CGFloat {
        get { return renderer.endAngle }
        set { renderer.endAngle = newValue }
    }

    public var trackStyle: TrackStyle {
        get { return renderer.trackStyle }
        set { renderer.trackStyle = newValue }
    }

    public var pointerStyle: PointerStyle {
        get { return renderer.pointerStyle }
        set { renderer.pointerStyle = newValue }
    }

    private let renderer = KnobRenderer()

    // Haptic feedback configuration
    public var hapticStyle: HapticFeedbackStyle = .stepAndBoundary
    public var stepInterval: CGFloat = 0.1
    public var stepFeedbackIntensity: CGFloat = 0.4
    public var boundaryFeedbackIntensity: CGFloat = 0.7

    private var lastBoundedAngle: CGFloat?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private var hasTriggeredBoundaryFeedback = false
    private var lastStepValue: Int = 0

    public private(set) var value: CGFloat = 0

    public func setValue(_ newValue: CGFloat, animated: Bool = false) {
        value = min(maximumValue, max(minimumValue, newValue))

        let angleRange = endAngle - startAngle
        let valueRange = maximumValue - minimumValue
        let angleValue = CGFloat(value - minimumValue) / CGFloat(valueRange) * angleRange + startAngle
        renderer.setPointerAngle(angleValue, animated: animated)
    }


    public var isContinuous = true

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        renderer.setPointerAngle(renderer.startAngle, animated: false)

        layer.addSublayer(renderer.trackLayer)
        layer.addSublayer(renderer.pointerLayer)

        let gestureRecognizer = RotationGestureRecognizer(target: self, action: #selector(Knob.handleGesture(_:)))
        addGestureRecognizer(gestureRecognizer)
    }

    @objc private func handleGesture(_ gesture: RotationGestureRecognizer) {
        // Initialize with current pointer angle when gesture begins
        if gesture.state == .began {
            lastBoundedAngle = renderer.pointerAngle
            hasTriggeredBoundaryFeedback = false
            lastStepValue = stepValueForCurrentValue()
            prepareFeedbackGenerators()
        }

        let midPointAngle = (2 * CGFloat(Double.pi) + startAngle - endAngle) / 2 + endAngle
        var boundedAngle = gesture.touchAngle
        if boundedAngle > midPointAngle {
            boundedAngle -= 2 * CGFloat(Double.pi)
        } else if boundedAngle < (midPointAngle - 2 * CGFloat(Double.pi)) {
            boundedAngle -= 2 * CGFloat(Double.pi)
        }

        boundedAngle = min(endAngle, max(startAngle, boundedAngle))

        var didHitBoundary = false

        // Hard stop: prevent jumping across the gap
        if let lastAngle = lastBoundedAngle {
            let angleDelta = abs(boundedAngle - lastAngle)
            let jumpThreshold = (endAngle - startAngle) * 0.5

            // If angle change exceeds threshold, it's likely a jump across the gap
            if angleDelta > jumpThreshold {
                didHitBoundary = true
                // Keep at the nearest boundary based on last position
                if lastAngle < startAngle + jumpThreshold {
                    boundedAngle = startAngle
                } else if lastAngle > endAngle - jumpThreshold {
                    boundedAngle = endAngle
                } else {
                    boundedAngle = lastAngle
                }
            }
        }

        lastBoundedAngle = boundedAngle

        // Calculate new value
        let angleRange = endAngle - startAngle
        let valueRange = maximumValue - minimumValue
        let angleValue = CGFloat(boundedAngle - startAngle) / CGFloat(angleRange) * valueRange + minimumValue

        // Trigger haptic feedback based on style
        triggerHapticFeedback(
            newValue: angleValue,
            isAtBoundary: boundedAngle <= startAngle || boundedAngle >= endAngle,
            didHitBoundary: didHitBoundary
        )

        // Reset when gesture ends
        if gesture.state == .ended || gesture.state == .cancelled {
            lastBoundedAngle = nil
            hasTriggeredBoundaryFeedback = false
        }

        setValue(angleValue)

        if isContinuous {
            sendActions(for: .valueChanged)
        } else {
            if gesture.state == .ended || gesture.state == .cancelled {
                sendActions(for: .valueChanged)
            }
        }

        // Notify gesture ended
        if gesture.state == .ended || gesture.state == .cancelled {
            sendActions(for: .editingDidEnd)
        }
    }

    private func prepareFeedbackGenerators() {
        if hapticStyle != .none {
            feedbackGenerator.prepare()
        }
    }

    private func stepValueForCurrentValue() -> Int {
        guard stepInterval > 0 else { return 0 }
        return Int(value / stepInterval)
    }

    private func triggerHapticFeedback(newValue: CGFloat, isAtBoundary: Bool, didHitBoundary: Bool) {
        guard hapticStyle != .none else { return }

        let shouldTriggerBoundary = hapticStyle == .boundary || hapticStyle == .stepAndBoundary
        let shouldTriggerStep = hapticStyle == .step || hapticStyle == .stepAndBoundary

        // Boundary feedback
        if shouldTriggerBoundary {
            if didHitBoundary {
                // Hard stop: use full intensity
                feedbackGenerator.impactOccurred(intensity: 1.0)
                hasTriggeredBoundaryFeedback = true
            } else if isAtBoundary && !hasTriggeredBoundaryFeedback {
                feedbackGenerator.impactOccurred(intensity: boundaryFeedbackIntensity)
                hasTriggeredBoundaryFeedback = true
            } else if !isAtBoundary {
                hasTriggeredBoundaryFeedback = false
            }
        }

        // Step feedback
        if shouldTriggerStep && stepInterval > 0 {
            let currentStepValue = Int(newValue / stepInterval)
            if currentStepValue != lastStepValue {
                // Avoid triggering step feedback at boundary (already handled by boundary feedback)
                let isAtExactBoundary = newValue <= minimumValue || newValue >= maximumValue
                if !shouldTriggerBoundary || !isAtExactBoundary {
                    feedbackGenerator.impactOccurred(intensity: stepFeedbackIntensity)
                }
                lastStepValue = currentStepValue
            }
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        renderer.updateBounds(bounds)
    }

    // MARK: - Geometry helpers for external use

    public func angle(for value: CGFloat) -> CGFloat {
        let clampedValue = min(maximumValue, max(minimumValue, value))
        let angleRange = endAngle - startAngle
        let valueRange = maximumValue - minimumValue
        return (clampedValue - minimumValue) / valueRange * angleRange + startAngle
    }

    public var trackRadius: CGFloat {
        var pointerLength: CGFloat = 6
        var lineWidth: CGFloat = 2
        if case .drawing(let length, let lw, _) = pointerStyle {
            pointerLength = length
            lineWidth = lw
        }
        if case .drawing(let lw, _) = trackStyle {
            lineWidth = max(lineWidth, lw)
        }
        let offset = max(pointerLength, lineWidth / 2)
        return min(bounds.width, bounds.height) / 2 - offset
    }

    public var trackCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
}

private class KnobRenderer {
    var startAngle: CGFloat = CGFloat(-Double.pi) * 11 / 8 {
        didSet {
            updateTrackLayer()
        }
    }

    var endAngle: CGFloat = CGFloat(Double.pi) * 3 / 8 {
        didSet {
            updateTrackLayer()
        }
    }

    var trackStyle: TrackStyle = .drawing() {
        didSet {
            updateTrackLayer()
        }
    }

    var pointerStyle: PointerStyle = .drawing() {
        didSet {
            updatePointerLayer()
        }
    }

    private(set) var pointerAngle: CGFloat = CGFloat(-Double.pi) * 11 / 8

    let trackLayer = CALayer()
    let pointerLayer = CALayer()

    private let trackShapeLayer = CAShapeLayer()
    private let trackImageLayer = CALayer()
    private let pointerShapeLayer = CAShapeLayer()
    private let pointerImageLayer = CALayer()

    init() {
        trackShapeLayer.fillColor = UIColor.clear.cgColor
        pointerShapeLayer.fillColor = UIColor.clear.cgColor

        trackLayer.addSublayer(trackShapeLayer)
        trackLayer.addSublayer(trackImageLayer)
        pointerLayer.addSublayer(pointerShapeLayer)
        pointerLayer.addSublayer(pointerImageLayer)
    }

    func setPointerAngle(_ newPointerAngle: CGFloat, animated: Bool = false) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        pointerLayer.transform = CATransform3DMakeRotation(newPointerAngle, 0, 0, 1)

        if animated {
            let midAngleValue = (max(newPointerAngle, pointerAngle) - min(newPointerAngle, pointerAngle)) / 2
                + min(newPointerAngle, pointerAngle)
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.values = [pointerAngle, midAngleValue, newPointerAngle]
            animation.keyTimes = [0.0, 0.5, 1.0]
            animation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
            pointerLayer.add(animation, forKey: nil)
        }

        CATransaction.commit()
        pointerAngle = newPointerAngle
    }

    func updateBounds(_ bounds: CGRect) {
        trackLayer.bounds = bounds
        trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        trackShapeLayer.bounds = bounds
        trackShapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        trackImageLayer.bounds = bounds
        trackImageLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        pointerLayer.bounds = bounds
        pointerLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        pointerShapeLayer.bounds = bounds
        pointerShapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        pointerImageLayer.bounds = bounds
        pointerImageLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        updateTrackLayer()
        updatePointerLayer()
    }

    private func updateTrackLayer() {
        switch trackStyle {
        case .drawing(let lineWidth, let color):
            trackShapeLayer.isHidden = false
            trackImageLayer.isHidden = true
            updateTrackShapePath(lineWidth: lineWidth, color: color)

        case .image(let image, let contentMode):
            trackShapeLayer.isHidden = true
            trackImageLayer.isHidden = false
            updateTrackImage(image: image, contentMode: contentMode)
        }
    }

    private func updateTrackShapePath(lineWidth: CGFloat, color: UIColor) {
        let bounds = trackShapeLayer.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        var pointerLength: CGFloat = 6
        if case .drawing(let length, _, _) = pointerStyle {
            pointerLength = length
        }

        let offset = max(pointerLength, lineWidth / 2)
        let radius = min(bounds.width, bounds.height) / 2 - offset

        let ring = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle,
                                endAngle: endAngle, clockwise: true)
        trackShapeLayer.path = ring.cgPath
        trackShapeLayer.strokeColor = color.cgColor
        trackShapeLayer.lineWidth = lineWidth
    }

    private func updateTrackImage(image: UIImage, contentMode: UIView.ContentMode) {
        trackImageLayer.contents = image.cgImage
        trackImageLayer.contentsGravity = contentModeToContentsGravity(contentMode)
    }

    private func updatePointerLayer() {
        switch pointerStyle {
        case .drawing(let length, let lineWidth, let color):
            pointerShapeLayer.isHidden = false
            pointerImageLayer.isHidden = true
            updatePointerShapePath(length: length, lineWidth: lineWidth, color: color)

        case .image(let image, let size):
            pointerShapeLayer.isHidden = true
            pointerImageLayer.isHidden = false
            updatePointerImage(image: image, size: size)
        }
    }

    private func updatePointerShapePath(length: CGFloat, lineWidth: CGFloat, color: UIColor) {
        let bounds = pointerShapeLayer.bounds

        let pointer = UIBezierPath()
        pointer.move(to: CGPoint(x: bounds.width - length - lineWidth / 2, y: bounds.midY))
        pointer.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))

        pointerShapeLayer.path = pointer.cgPath
        pointerShapeLayer.strokeColor = color.cgColor
        pointerShapeLayer.lineWidth = lineWidth
    }

    private func updatePointerImage(image: UIImage, size: CGSize?) {
        let bounds = pointerImageLayer.bounds
        let imageSize = size ?? image.size

        // Position image at the right edge, centered vertically
        let imageFrame = CGRect(
            x: bounds.width - imageSize.width,
            y: (bounds.height - imageSize.height) / 2,
            width: imageSize.width,
            height: imageSize.height
        )

        pointerImageLayer.contents = image.cgImage
        pointerImageLayer.frame = imageFrame
        pointerImageLayer.contentsGravity = .resizeAspect
    }

    private func contentModeToContentsGravity(_ contentMode: UIView.ContentMode) -> CALayerContentsGravity {
        switch contentMode {
        case .scaleToFill: return .resize
        case .scaleAspectFit: return .resizeAspect
        case .scaleAspectFill: return .resizeAspectFill
        case .center: return .center
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .left
        case .right: return .right
        case .topLeft: return .topLeft
        case .topRight: return .topRight
        case .bottomLeft: return .bottomLeft
        case .bottomRight: return .bottomRight
        @unknown default: return .resizeAspect
        }
    }
}
