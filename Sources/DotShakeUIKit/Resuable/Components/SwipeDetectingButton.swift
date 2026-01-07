//
//  SwipeDetectingButton.swift
//  DotShakeUIKit
//
//  Created by ChenZhen on 4/7/25.
//

import UIKit

public final class SwipeDetectingButton: UIButton {
    
    public var swipeThreshold: CGFloat = 30.0

    public var onTap: (() -> Void)?

    public var onSwipe: (() -> Void)?
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        return tap
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        return pan
    }()
    
    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestures()
    }
    
    private func setupGestures() {
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Gesture Handlers
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            onTap?()
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .ended else { return }

        let translation = gesture.translation(in: self)
        let distance = hypot(translation.x, translation.y)
        
        if distance > swipeThreshold {
            onSwipe?()
        }
    }
}

// MARK: - Gesture Delegate
extension SwipeDetectingButton: UIGestureRecognizerDelegate {
    
    // Allow tap and pan gestures to be recognized simultaneously
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // Make tap fail when pan is recognized (mutually exclusive)
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer,
           otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
}
