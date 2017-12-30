//
//  BaseViewController.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 08/12/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//

import UIKit
import ESPullToRefresh

class BaseViewController: UIViewController {

  // MARK: - Variables
  var navigationBarGradient: CAGradientLayer?

  // MARK: - Lifecycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    addNavigationBarGradient()
  }

  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    addNavigationBarGradient()
  }
  
  func snapshotViewForTransition() -> UIView {
    preconditionFailure("Must Override")
  }
  
  func snapshotViewInitialFrame() -> CGRect {
    preconditionFailure("Must Override")
  }
  
  // MARK: - Public Methods
  func addNavigationBarGradient() {
    removeNavigationBarGradient()
    navigationBarGradient = GradientHelper.createNavigationBarGradient(with: CGRect(origin: .zero, size: CGSize(width: UIApplication.shared.statusBarFrame.width, height: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height)))
    view.layer.addSublayer(navigationBarGradient!)
  }
  
  func removeNavigationBarGradient() {
    navigationBarGradient?.removeFromSuperlayer()
  }
}
