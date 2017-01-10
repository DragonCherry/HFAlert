//
//  HFAlert.swift
//  Pods
//
//  Created by DragonCherry on 1/10/17.
//
//

import UIKit

open class HFAlert: NSObject {
    
    fileprivate weak var parent: UIViewController?
    fileprivate var alertController: UIAlertController?
    fileprivate var forceDismiss: Bool = false
    open var isShowing: Bool = false
    
    fileprivate var dismissHandler: ((Int) -> Void)?
    fileprivate var cancelHandler: (() -> Void)?
    fileprivate var destructHandler: (() -> Void)?
    
    fileprivate var promptHandler: ((Int, String?) -> Void)?
    fileprivate var promptTextField: UITextField?
    
    public required override init() {
    }
    
    open func show(
        _ parent: UIViewController,
        style: UIAlertControllerStyle = .alert,
        title: String?,
        message: String?,
        dismissTitle: String) {
        
        self.show(
            parent,
            style: style,
            title: title,
            message: message,
            cancelTitle: nil,
            onCancel: nil,
            otherTitles: [dismissTitle],
            onDismiss: nil)
    }
    
    open func show(
        _ parent: UIViewController,
        style: UIAlertControllerStyle = .alert,
        title: String?,
        message: String?,
        dismissTitle: String,
        onDismiss: (() -> Void)?) {
        
        self.show(
            parent,
            style: style,
            title: title,
            message: message,
            cancelTitle: dismissTitle,
            onCancel: { onDismiss?() },
            otherTitles: nil,
            onDismiss: nil)
    }
    
    open func show(
        _ parent: UIViewController,
        style: UIAlertControllerStyle = .alert,
        title: String?,
        message: String?,
        cancelTitle: String? = nil,
        onCancel: (() -> Void)? = nil,
        otherTitles: [String]? = nil,
        onDismiss: ((Int) -> Void)? = nil,
        destructTitle: String? = nil,
        onDestruct: (() -> Void)? = nil) {
        
        self.parent = parent
        self.dismissHandler = onDismiss
        self.cancelHandler = onCancel
        self.destructHandler = onDestruct
        
        self.close(false)
        
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        guard let alertController = self.alertController else {
            return
        }
        
        if let otherTitles = otherTitles {
            for (index, otherTitle) in otherTitles.enumerated() {
                let dismissAction: UIAlertAction = UIAlertAction(title: otherTitle, style: .default, handler: { action in
                    self.dismissHandler?(index)
                    self.clear()
                })
                alertController.addAction(dismissAction)
            }
        }
        
        if let cancelTitle = cancelTitle {
            let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { action in
                self.cancelHandler?()
                self.clear()
            })
            alertController.addAction(cancelAction)
        }
        
        if let destructTitle = destructTitle {
            let destructAction: UIAlertAction = UIAlertAction(title: destructTitle, style: .destructive, handler: { action in
                self.destructHandler?()
                self.clear()
            })
            alertController.addAction(destructAction)
        }
        
        if let parent = self.parent {
            parent.present(alertController, animated: true, completion: nil)
        } else {
            print("Cannot find parent while presenting alert.")
        }
        
        self.isShowing = true
    }
    
    open func prompt(
        
        _ parent: UIViewController,
        title: String?,
        message: String?,
        defaultText: String? = nil,
        cancelTitle: String? = nil,
        onCancel: (() -> Void)? = nil,
        otherTitles: [String]? = nil,
        onPrompt: ((Int, String?) -> Void)? = nil) {
        
        close(false)
        
        self.parent = parent
        self.promptHandler = onPrompt
        self.cancelHandler = onCancel
        
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let alertController = self.alertController else {
            return
        }
        
        alertController.addTextField(configurationHandler: { textField in
            textField.text = defaultText
            self.promptTextField = textField
        })
        
        if let otherTitles = otherTitles {
            for (index, otherTitle) in otherTitles.enumerated() {
                let dismissAction: UIAlertAction = UIAlertAction(title: otherTitle, style: .default, handler: { action in
                    self.promptTextField?.resignFirstResponder()
                    self.promptHandler?(index, self.promptTextField!.text)
                    self.clear()
                })
                alertController.addAction(dismissAction)
            }
        }
        
        if let cancelTitle = cancelTitle {
            let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { action in
                self.promptTextField?.resignFirstResponder()
                self.cancelHandler?()
                self.clear()
            })
            alertController.addAction(cancelAction)
        }
        
        if let parent = self.parent {
            parent.present(alertController, animated: true, completion: nil)
        } else {
            print("Cannot find parent while presenting alert.")
        }
        
        isShowing = true
    }
    
    fileprivate func autoDismiss() {
        close()
    }
    
    open func close(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        if isShowing {
            alertController?.dismiss(animated: animated, completion: {
                completion?()
            })
        }
        clear()
        isShowing = false
    }
    
    private func clear() {
        self.parent = nil
        self.alertController = nil
        self.promptTextField = nil
        self.cancelHandler = nil
        self.dismissHandler = nil
        self.destructHandler = nil
    }
}
