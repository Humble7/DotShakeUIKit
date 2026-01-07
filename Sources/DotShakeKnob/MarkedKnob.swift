//
//  MarkedKnob.swift
//  DotShakeKnob
//
//  Created by ChenZhen on 6/1/26.
//

import UIKit

// MARK: - Configuration Structs

public struct MarkerStyle: Sendable {
    public var color: UIColor
    public var length: CGFloat
    public var lineWidth: CGFloat
    public var tolerance: CGFloat

    public static let `default` = MarkerStyle(
        color: .systemRed,
        length: 15,
        lineWidth: 2,
        tolerance: 0.02
    )

    public init(color: UIColor, length: CGFloat, lineWidth: CGFloat, tolerance: CGFloat) {
        self.color = color
        self.length = length
        self.lineWidth = lineWidth
        self.tolerance = tolerance
    }
}

public struct SnapBehavior: Sendable {
    public var enabled: Bool
    public var threshold: CGFloat
    public var animated: Bool

    public static let `default` = SnapBehavior(
        enabled: true,
        threshold: 0.05,
        animated: true
    )

    public static let disabled = SnapBehavior(
        enabled: false,
        threshold: 0,
        animated: false
    )

    public init(enabled: Bool, threshold: CGFloat, animated: Bool) {
        self.enabled = enabled
        self.threshold = threshold
        self.animated = animated
    }
}

public struct SymbolStyle: Sendable {
    public var color: UIColor
    public var activeColor: UIColor
    public var size: CGFloat
    public var lineWidth: CGFloat
    public var tapRadius: CGFloat

    public static let `default` = SymbolStyle(
        color: .systemBlue,
        activeColor: .systemRed,
        size: 20,
        lineWidth: 2,
        tapRadius: 22
    )

    public init(color: UIColor, activeColor: UIColor, size: CGFloat, lineWidth: CGFloat, tapRadius: CGFloat) {
        self.color = color
        self.activeColor = activeColor
        self.size = size
        self.lineWidth = lineWidth
        self.tapRadius = tapRadius
    }
}

// MARK: - Marker Data

public struct KnobMarker: Codable, @unchecked Sendable {
    public let value: CGFloat
    public let color: UIColor
    public let length: CGFloat
    public let lineWidth: CGFloat

    enum CodingKeys: String, CodingKey {
        case value, length, lineWidth
        case colorComponents
    }

    public init(value: CGFloat, color: UIColor, length: CGFloat, lineWidth: CGFloat) {
        self.value = value
        self.color = color
        self.length = length
        self.lineWidth = lineWidth
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(CGFloat.self, forKey: .value)
        length = try container.decode(CGFloat.self, forKey: .length)
        lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)

        let components = try container.decode([CGFloat].self, forKey: .colorComponents)
        if components.count >= 4 {
            color = UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        } else {
            color = .systemRed
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(length, forKey: .length)
        try container.encode(lineWidth, forKey: .lineWidth)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        try container.encode([r, g, b, a], forKey: .colorComponents)
    }
}

open class MarkedKnob: UIControl {

    // MARK: - Public Properties

    public private(set) var knob = Knob()

    public var markers: [KnobMarker] = [] {
        didSet {
            updateMarkerLayers()
            setNeedsDisplay()
            onMarkersChanged?(markers)
        }
    }

    public var onMarkersChanged: (([KnobMarker]) -> Void)?

    public var markerStyle: MarkerStyle = .default {
        didSet {
            updateMarkerLayers()
        }
    }

    public var snapBehavior: SnapBehavior = .default

    public var symbolStyle: SymbolStyle = .default {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - Private Properties

    private var markerLayers: [CAShapeLayer] = []
    private let markersContainer = CALayer()
    private let tapGesture = UITapGestureRecognizer()

    private var isAtMarker: Bool {
        return markerAtCurrentPosition != nil
    }

    private var markerAtCurrentPosition: Int? {
        for (index, marker) in markers.enumerated() {
            if abs(knob.value - marker.value) <= markerStyle.tolerance {
                return index
            }
        }
        return nil
    }

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        setupKnob()
        setupMarkersContainer()
        setupTapGesture()
    }

    private func setupKnob() {
        knob.translatesAutoresizingMaskIntoConstraints = false
        addSubview(knob)

        NSLayoutConstraint.activate([
            knob.topAnchor.constraint(equalTo: topAnchor),
            knob.leadingAnchor.constraint(equalTo: leadingAnchor),
            knob.trailingAnchor.constraint(equalTo: trailingAnchor),
            knob.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        knob.addTarget(self, action: #selector(knobValueChanged), for: .valueChanged)
        knob.addTarget(self, action: #selector(knobGestureEnded), for: .editingDidEnd)
    }

    private func setupMarkersContainer() {
        layer.addSublayer(markersContainer)
    }

    private func setupTapGesture() {
        tapGesture.addTarget(self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        markersContainer.frame = bounds
        updateMarkerLayers()
    }

    // MARK: - Drawing

    open override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let halfSize = symbolStyle.size / 2

        // Set color based on state
        let color = isAtMarker ? symbolStyle.activeColor : symbolStyle.color
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(symbolStyle.lineWidth)
        context.setLineCap(.round)

        if isAtMarker {
            // Draw minus sign (-)
            context.move(to: CGPoint(x: center.x - halfSize, y: center.y))
            context.addLine(to: CGPoint(x: center.x + halfSize, y: center.y))
        } else {
            // Draw plus sign (+)
            // Horizontal line
            context.move(to: CGPoint(x: center.x - halfSize, y: center.y))
            context.addLine(to: CGPoint(x: center.x + halfSize, y: center.y))
            // Vertical line
            context.move(to: CGPoint(x: center.x, y: center.y - halfSize))
            context.addLine(to: CGPoint(x: center.x, y: center.y + halfSize))
        }

        context.strokePath()
    }

    // MARK: - Actions

    @objc private func knobValueChanged() {
        setNeedsDisplay()
        sendActions(for: .valueChanged)
    }

    @objc private func knobGestureEnded() {
        guard snapBehavior.enabled, !markers.isEmpty else { return }
        snapToNearestMarkerIfNeeded()
        sendActions(for: .editingDidEnd)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let distance = hypot(location.x - center.x, location.y - center.y)

        // Only respond to taps in center region
        guard distance <= symbolStyle.tapRadius else { return }

        if let markerIndex = markerAtCurrentPosition {
            removeMarker(at: markerIndex)
            // Haptic feedback for remove
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } else {
            addMarkerAtCurrentPosition()
            // Haptic feedback for add
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }

    // MARK: - Marker Management

    public func addMarkerAtCurrentPosition() {
        let marker = KnobMarker(
            value: knob.value,
            color: markerStyle.color,
            length: markerStyle.length,
            lineWidth: markerStyle.lineWidth
        )
        markers.append(marker)
    }

    public func addMarker(at value: CGFloat, color: UIColor? = nil, length: CGFloat? = nil, lineWidth: CGFloat? = nil) {
        let marker = KnobMarker(
            value: value,
            color: color ?? markerStyle.color,
            length: length ?? markerStyle.length,
            lineWidth: lineWidth ?? markerStyle.lineWidth
        )
        markers.append(marker)
    }

    public func removeMarker(at index: Int) {
        guard index >= 0 && index < markers.count else { return }
        markers.remove(at: index)
    }

    public func removeAllMarkers() {
        markers.removeAll()
    }

    // MARK: - Snap Logic

    private func snapToNearestMarkerIfNeeded() {
        let currentValue = knob.value

        var nearestMarker: KnobMarker?
        var nearestDistance: CGFloat = .greatestFiniteMagnitude

        for marker in markers {
            let distance = abs(currentValue - marker.value)
            if distance <= snapBehavior.threshold && distance < nearestDistance {
                nearestDistance = distance
                nearestMarker = marker
            }
        }

        if let marker = nearestMarker {
            knob.setValue(marker.value, animated: snapBehavior.animated)
            setNeedsDisplay()

            // Notify value changed after snap
            sendActions(for: .valueChanged)

            // Haptic feedback for snap
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }
    }

    // MARK: - Marker Layers

    private func updateMarkerLayers() {
        markerLayers.forEach { $0.removeFromSuperlayer() }
        markerLayers.removeAll()

        guard bounds.width > 0 else { return }

        for marker in markers {
            let layer = createMarkerLayer(for: marker)
            markersContainer.addSublayer(layer)
            markerLayers.append(layer)
        }
    }

    private func createMarkerLayer(for marker: KnobMarker) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let center = knob.trackCenter
        let radius = knob.trackRadius
        let angle = knob.angle(for: marker.value)

        let outerPoint = CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
        let innerPoint = CGPoint(
            x: center.x + (radius - marker.length) * cos(angle),
            y: center.y + (radius - marker.length) * sin(angle)
        )

        let path = UIBezierPath()
        path.move(to: outerPoint)
        path.addLine(to: innerPoint)

        layer.path = path.cgPath
        layer.strokeColor = marker.color.cgColor
        layer.lineWidth = marker.lineWidth
        layer.lineCap = .round

        return layer
    }
}

// MARK: - Public Value Accessors

public extension MarkedKnob {
    var value: CGFloat {
        get { knob.value }
    }

    func setValue(_ newValue: CGFloat, animated: Bool = false) {
        knob.setValue(newValue, animated: animated)
        setNeedsDisplay()
    }

    var minimumValue: CGFloat {
        get { knob.minimumValue }
        set { knob.minimumValue = newValue }
    }

    var maximumValue: CGFloat {
        get { knob.maximumValue }
        set { knob.maximumValue = newValue }
    }

    var trackStyle: TrackStyle {
        get { knob.trackStyle }
        set { knob.trackStyle = newValue }
    }

    var pointerStyle: PointerStyle {
        get { knob.pointerStyle }
        set { knob.pointerStyle = newValue }
    }

    var hapticStyle: HapticFeedbackStyle {
        get { knob.hapticStyle }
        set { knob.hapticStyle = newValue }
    }

    var stepInterval: CGFloat {
        get { knob.stepInterval }
        set { knob.stepInterval = newValue }
    }

    var stepFeedbackIntensity: CGFloat {
        get { knob.stepFeedbackIntensity }
        set { knob.stepFeedbackIntensity = newValue }
    }

    var boundaryFeedbackIntensity: CGFloat {
        get { knob.boundaryFeedbackIntensity }
        set { knob.boundaryFeedbackIntensity = newValue }
    }
}
