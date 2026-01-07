//
//  TransparentPassthroughView.swift
//  DotShakeUIKit
//
//  Created by ChenZhen on 9/6/25.
//

import UIKit

extension UIView {
    private struct AssociatedKeys {
        @MainActor static var passthroughKey: UInt8 = 0
    }

    public var isPassthroughEnabled: Bool {
        get {
            guard self is TransparentPassthroughView else { return false }
            return objc_getAssociatedObject(self, &AssociatedKeys.passthroughKey) as? Bool ?? false
        }
        set {
            guard self is TransparentPassthroughView else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.passthroughKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public class TransparentPassthroughView: UIView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isPassthroughEnabled else {
            return super.hitTest(point, with: event)
        }

        for subview in subviews.reversed() {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }
        return nil
    }
}
