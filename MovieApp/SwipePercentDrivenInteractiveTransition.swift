//
//  SwipePercentDrivenInteractiveTransition.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 23/07/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//

import UIKit

class SwipePercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {

  // MARK: - Variables
  var scaleTransitionAnimator: ScaleTransitionAnimator!
  var isInteractionInProgress = false
  private var shouldCompleteTransition = false
  private weak var viewController: UIViewController!

  // MARK: - Add Gesture
  func wireTo(viewController: UIViewController) {
    self.viewController = viewController
    DispatchQueue.main.async { [weak self] in
      self?.prepareGestureRecognizer(in: viewController.view)
    }
  }

  // MARK :- Swipe gesture for interactive transition
  private func prepareGestureRecognizer(in view: UIView) {
    let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    view.addGestureRecognizer(gesture)
  }

  @objc private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
    let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
    var progress = (translation.y / (UIScreen.main.bounds.size.height - 100))
    progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 0.5))

    switch gestureRecognizer.state {
      
    case .began:
      isInteractionInProgress = true
      viewController.navigationController?.popViewController(animated: true)
      completionSpeed = 0.999  // https://stackoverflow.com/a/22968139
      
    case .changed:
      shouldCompleteTransition = progress > 0.2
      update(progress)
      
    case .cancelled:
      isInteractionInProgress = false
      cancel()
      
    case .ended:
      isInteractionInProgress = false
      
      if !shouldCompleteTransition {
        cancel()
      } else {
        finish()
      }
      
    default:
      print("Not Supported")
    }

    scaleTransitionAnimator.handlePanGesture(gestureRecognizer, progress: progress)
  }
}
