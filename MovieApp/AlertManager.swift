//
//  AlertManager.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 12/12/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//

typealias alertManagerActionHandler = ((UIAlertAction) -> Void)?

class AlertManager {
  class func showSuccess(_ message: String, viewController: UIViewController, title: String = "Success!") {
    AlertManager.showOptions(title: NSLocalizedString(title, comment: ""),
                             message: NSLocalizedString(message, comment: ""),
                             viewController: viewController,
                             options: [(title: NSLocalizedString("Okay", comment: ""), handler: nil)])
  }
  
  class func showError(_ message: String, viewController: UIViewController, title: String = "Error!", dismissHandler: ((UIAlertAction?) -> Void)? = nil ) {
    AlertManager.showOptions(title: NSLocalizedString(title, comment: ""),
                             message: NSLocalizedString(message, comment: ""),
                             viewController: viewController,
                             options: [(title: NSLocalizedString("Dismiss", comment: ""), handler: dismissHandler)])
  }
  
  class func showOptions(title: String, message: String, viewController: UIViewController?, options: [(title: String, handler: alertManagerActionHandler)]) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    for (optionTitle, optionHandler) in options {
      alertController.addAction(UIAlertAction(title: optionTitle, style: .default, handler: optionHandler))
    }
    
    viewController?.present(alertController, animated: true, completion: nil)
  }
}
