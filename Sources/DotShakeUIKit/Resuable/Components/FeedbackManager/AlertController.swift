//
//  AlertController.swift
//  DotShakeUIKit
//
//  Created by ChenZhen on 26/6/25.
//

import UIKit

@MainActor
public final class AlertController {
    public func show(title: String?,
              message: String?,
              confirmTitle: String = "OK",
              cancelTitle: String? = nil,
              onConfirm: (() -> Void)? = nil,
              onCancel: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            guard let topVC = UIViewController().topViewController() else { return }

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            if let cancel = cancelTitle {
                alert.addAction(UIAlertAction(title: cancel, style: .cancel) { _ in
                    onCancel?()
                })
            }

            alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
                onConfirm?()
            })

            topVC.present(alert, animated: true, completion: nil)
        }
    }
}
