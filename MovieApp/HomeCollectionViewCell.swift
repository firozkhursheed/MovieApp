//
//  HomeCollectionViewCell.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 22/07/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//

import UIKit
import Kingfisher

class HomeCollectionViewCell: UICollectionViewCell {

  // MARK: - Constants
  static let verticalPadding = CGFloat(20)
  static let detailHeight = CGFloat(51.5)
  
  // MARK: - IBOutlet
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // MARK: - Variables
  var movie: Movie! {
    didSet {
      activityIndicator.startAnimating()
      imageView.kf.setImage(with: movie.imageUrl, placeholder: nil, options: nil, progressBlock: nil) { [weak self] (_, _, _, _) in
        self?.activityIndicator.stopAnimating()
      }
      
      titleLabel.text = movie.originalTitle
      genreLabel.text = "Popularity: " + String(movie.popularity)
    }
  }

  // MARK: - Lifecycle
  override func awakeFromNib() {
    super.awakeFromNib()

    setupViewUI()
    addCornerRadiusToImage()
  }

  // MARK: - Animation Helpers
  func snapshot() -> UIView {
    return imageView.snapshotView(afterScreenUpdates: true) ?? imageView
  }
  
  // MARK: - UI Decoration Methods
  private func setupViewUI() {
    layer.shadowColor = UIColor.pictonBlue.cgColor
    layer.shadowOpacity = 0.8
    layer.shadowRadius = 3.0
    layer.shadowOffset = CGSize(width: 0.0, height: 0.6)
    layer.cornerRadius = 4
  }
  
  private func addCornerRadiusToImage() {
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 4
  }
}
