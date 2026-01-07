//
//  ViewControllerContainment.swift
//  DotShakeUIKit
//
//  Created by ChenZhen on 2/10/25.
//

import UIKit

extension UIViewController {
    
    // MARK: - Methods
    public func addFullScreen(childViewController child: UIViewController) {
        guard child.parent == nil else {
            return
        }
        
        addChild(child)
        view.addSubview(child.view)
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: child.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: child.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: child.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: child.view.bottomAnchor)
        ])
        
        child.didMove(toParent: self)
    }
    
    public func remove(childViewController child: UIViewController?) {
        guard let child else {
            return
        }
        
        guard child.parent != nil else {
            return
        }
        
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    public func add(childViewController child: UIViewController?, constraintChildView: ((_ child: UIView) -> Void)? = nil) {
        guard let child else {
            return
        }
        
        guard child.parent == nil else {
            return
        }
        
        addChild(child)
        view.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        constraintChildView?(child.view)
        child.didMove(toParent: self)
    }

}
