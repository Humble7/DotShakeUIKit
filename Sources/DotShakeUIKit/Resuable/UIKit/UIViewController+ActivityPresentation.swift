//
//  File.swift
//  DotShakeUIKit
//
//  Created by ChenZhen on 3/11/25.
//

import UIKit

public extension UIViewController {
    func presentActivityVC(with activityItems: [Any]) {
        guard let sourceVC = topViewController() else {
            return
        }
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sourceVC.view
            popover.sourceRect = CGRect(x: sourceVC.view.bounds.midX, y: sourceVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        sourceVC.present(activityVC, animated: true)
    }
}
