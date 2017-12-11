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
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addNavigationBarGradient()
  }
  
  func snapshotViewForTransition() -> UIView {
    fatalError("Must Override")
  }
  
  func snapshotViewInitialFrame() -> CGRect {
    fatalError("Must Override")
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
