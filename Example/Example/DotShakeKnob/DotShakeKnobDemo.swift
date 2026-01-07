//
//  DotShakeKnobDemo.swift
//  Example
//
//  Created by ChenZhen on 7/1/26.
//

import UIKit
import DotShakeKnob

class DotShakeKnobDemoVC: UIViewController {

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .monospacedDigitSystemFont(ofSize: 48, weight: .medium)
        label.text = "0.00"
        return label
    }()

    private lazy var valueSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.addTarget(self, action: #selector(handleSliderChanged(_:)), for: .valueChanged)
        return slider
    }()

    private lazy var animateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Animate"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var animateSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.isOn = true
        return switchView
    }()

    private lazy var randomButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Random Value", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.addTarget(self, action: #selector(handleRandomButtonPressed(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var addMarkerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Marker", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.addTarget(self, action: #selector(handleAddMarkerPressed(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var clearMarkersButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear Markers", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.addTarget(self, action: #selector(handleClearMarkersPressed(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var markerCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.text = "Markers: 0"
        return label
    }()

    private var markedKnob: MarkedKnob = {
        let knob = MarkedKnob()
        knob.translatesAutoresizingMaskIntoConstraints = false
        return knob
    }()

    private var markerBinding: MarkerBinding?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DotShakeKnob"
        setupUI()
        setupKnob()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(markedKnob)
        view.addSubview(valueLabel)
        view.addSubview(valueSlider)
        view.addSubview(animateLabel)
        view.addSubview(animateSwitch)
        view.addSubview(randomButton)
        view.addSubview(addMarkerButton)
        view.addSubview(clearMarkersButton)
        view.addSubview(markerCountLabel)

        NSLayoutConstraint.activate([
            markedKnob.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            markedKnob.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            markedKnob.widthAnchor.constraint(equalToConstant: 120),
            markedKnob.heightAnchor.constraint(equalToConstant: 120),

            valueLabel.topAnchor.constraint(equalTo: markedKnob.bottomAnchor, constant: 24),
            valueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            markerCountLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            markerCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            valueSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            valueSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            valueSlider.topAnchor.constraint(equalTo: markerCountLabel.bottomAnchor, constant: 30),

            animateLabel.trailingAnchor.constraint(equalTo: animateSwitch.leadingAnchor, constant: -8),
            animateLabel.centerYAnchor.constraint(equalTo: animateSwitch.centerYAnchor),

            animateSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 40),
            animateSwitch.topAnchor.constraint(equalTo: valueSlider.bottomAnchor, constant: 30),

            randomButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            randomButton.topAnchor.constraint(equalTo: animateSwitch.bottomAnchor, constant: 30),

            addMarkerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addMarkerButton.topAnchor.constraint(equalTo: randomButton.bottomAnchor, constant: 16),

            clearMarkersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearMarkersButton.topAnchor.constraint(equalTo: addMarkerButton.bottomAnchor, constant: 16),
        ])
    }

    private func setupKnob() {
        // Style configuration
        markedKnob.trackStyle = .drawing(lineWidth: 4, color: .systemGray3)
        markedKnob.pointerStyle = .drawing(length: 14, lineWidth: 4, color: .systemBlue)

        // Haptic feedback configuration
        markedKnob.hapticStyle = .stepAndBoundary
        markedKnob.stepInterval = 0.1
        markedKnob.stepFeedbackIntensity = 0.5
        markedKnob.boundaryFeedbackIntensity = 0.8

        // Marker configuration
        markedKnob.markerStyle = MarkerStyle(
            color: .systemRed,
            length: 12,
            lineWidth: 3,
            tolerance: 0.05
        )
        markedKnob.snapBehavior = SnapBehavior(
            enabled: true,
            threshold: 0.08,
            animated: true
        )
        markedKnob.symbolStyle = SymbolStyle(
            color: .systemBlue,
            activeColor: .systemRed,
            size: 20,
            lineWidth: 2,
            tapRadius: 20
        )

        // Bind storage for persistence
        markerBinding = markedKnob.bindStorage(key: "demoKnob")

        // Listen for value changes
        markedKnob.addTarget(self, action: #selector(handleKnobValueChanged(_:)), for: .valueChanged)

        // Listen for marker changes
        markedKnob.onMarkersChanged = { [weak self] markers in
            self?.markerCountLabel.text = "Markers: \(markers.count)"
        }

        updateLabel()
        markerCountLabel.text = "Markers: \(markedKnob.markers.count)"
    }

    @objc private func handleSliderChanged(_ sender: UISlider) {
        markedKnob.setValue(CGFloat(sender.value), animated: false)
        updateLabel()
    }

    @objc private func handleKnobValueChanged(_ sender: MarkedKnob) {
        valueSlider.value = Float(sender.value)
        updateLabel()
    }

    @objc private func handleRandomButtonPressed(_ sender: UIButton) {
        let randomValue = CGFloat.random(in: 0...1)
        markedKnob.setValue(randomValue, animated: animateSwitch.isOn)
        valueSlider.setValue(Float(randomValue), animated: animateSwitch.isOn)
        updateLabel()
    }

    @objc private func handleAddMarkerPressed(_ sender: UIButton) {
        markedKnob.addMarkerAtCurrentPosition()
    }

    @objc private func handleClearMarkersPressed(_ sender: UIButton) {
        markedKnob.removeAllMarkers()
    }

    private func updateLabel() {
        valueLabel.text = String(format: "%.2f", markedKnob.value)
    }
}

#Preview {
    UINavigationController(rootViewController: DotShakeKnobDemoVC())
}
