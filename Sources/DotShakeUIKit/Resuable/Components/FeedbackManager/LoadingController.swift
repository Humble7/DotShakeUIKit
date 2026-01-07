//
//  LoadingController.swift
//  DotShakeUIKit
//
//  Created by ChenZhen on 26/6/25.
//

import UIKit

@MainActor
public final class LoadingController {
    private let backgroundView = UIView()
    private let indicator = UIActivityIndicatorView(style: .large)
    private let textLabel = UILabel()
    private weak var currentWindow: UIWindow?

    public init() {
        setupViews()
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupViews() {
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.isUserInteractionEnabled = true

        indicator.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0

        backgroundView.addSubview(indicator)
        backgroundView.addSubview(textLabel)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -10),

            textLabel.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 16),
            textLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            textLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor, constant: 24),
            textLabel.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -24)
        ])
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc private func deviceOrientationDidChange() {
        guard let window = currentWindow else { return }

        backgroundView.frame = window.bounds

        backgroundView.setNeedsLayout()
        backgroundView.layoutIfNeeded()
    }

    public func show(text: String? = nil) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow }) else { return }

        currentWindow = window

        DispatchQueue.main.async {
            self.textLabel.text = text
            if self.backgroundView.superview == nil {
                self.backgroundView.frame = window.bounds
                window.addSubview(self.backgroundView)
            }
            self.indicator.startAnimating()
        }
    }

    public func update(text: String? = nil) {
        self.textLabel.text = text
        self.indicator.stopAnimating()
    }

    public func hide() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            self.backgroundView.removeFromSuperview()
            self.currentWindow = nil
        }
    }
}
