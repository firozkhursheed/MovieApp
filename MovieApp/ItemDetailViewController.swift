//
//  ItemDetailViewController.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 23/07/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//

class ItemDetailViewController: BaseViewController {

  // MARK: - IBOutlet
  @IBOutlet weak var itemImageView: UIImageView!
  @IBOutlet weak var itemTitle: UILabel!

  @IBOutlet weak var itemImageViewHeightLayoutConstraint: NSLayoutConstraint!

  // MARK: - Variables
  var movie: Movie!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    itemImageViewHeightLayoutConstraint.constant = itemImageView.image?.height(for: itemImageView.frame.size.width) ?? 300
  }
  
  override func snapshotViewForTransition() -> UIView {
    let snapshotView = itemImageView.snapshotView(afterScreenUpdates: true) ?? UIView()
    let snapshotOrigin = itemImageView.convert(CGPoint.zero, to: view)
    snapshotView.frame.origin = snapshotOrigin
    return snapshotView
  }

  override func snapshotViewInitialFrame() -> CGRect {
    view.layoutIfNeeded()
    return itemImageView.frame
  }
  
  // MARK: - Private Methods
  private func setupUI() {
    itemImageView.kf.setImage(with: movie.imageUrl)
    itemImageView.layer.masksToBounds = true

    itemTitle.text = movie.originalTitle
  }
}
