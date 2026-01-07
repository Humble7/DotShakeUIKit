//
//  File.swift
//  DotShakeUIKit
//
//  Created by ChenZhen on 3/10/25.
//

import UIKit
import Combine
import FoundationKit

extension UIViewController {
    public func present(errorMessage: ErrorMessage) {
        let errorAlertController = UIAlertController(title: errorMessage.title, message: errorMessage.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        errorAlertController.addAction(okAction)
        present(errorAlertController, animated: true, completion: nil)
    }
    
    public func present(errorMessage: ErrorMessage, withPresentationState errorPresentation: PassthroughSubject<ErrorPresentation?, Never>) {
        errorPresentation.send(.presenting)
        let errorAlertController = UIAlertController(title: errorMessage.title, message: errorMessage.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            errorPresentation.send(.dismissed)
            errorPresentation.send(nil)
        }
        errorAlertController.addAction(okAction)
        present(errorAlertController, animated: true, completion: nil)
    }
}
