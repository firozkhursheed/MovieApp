//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 22/07/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//

import CHTCollectionViewWaterfallLayout

class HomeViewController: BaseViewController {

  // MARK: - Constants
  static private let homeToItemDetailSegue = "homeToItemDetailSegueIdentifier"
  
  private let collectionViewLayoutSectionInsetValue = CGFloat(10)
  private let swipePercentDrivenInteractiveTransition = SwipePercentDrivenInteractiveTransition()

  // MARK: - IBOutlet
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var shadowTopView: UIView!
  
  // MARK: - Variables
  var currentIndexPath: IndexPath!
  
  private var orientationBeforeTransition: UIDeviceOrientation?
  
  private lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
    [unowned self] in
    
    let predicate = NSPredicate(format: "recordID != nil")
    return Movie.mr_fetchAllSorted(by: "popularity,voteAverage,recordID", ascending: false, with: predicate, groupBy: nil, delegate: self) as! NSFetchedResultsController<Movie>
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fetchMovies()
    setupGradientShadow()
    setupCollectionView()
    setupNavigationBar()
    setupOrientationInfo()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if segue.identifier == type(of: self).homeToItemDetailSegue {
      navigationController?.delegate = self
      let itemDetailViewController = segue.destination as! ItemDetailViewController
      itemDetailViewController.movie = sender as! Movie
      swipePercentDrivenInteractiveTransition.wireTo(viewController: itemDetailViewController)
    }
  }
  
  // MARK: - Private Methods
  private func setupCollectionView() {
    let nib = UINib(nibName: String(describing: HomeCollectionViewCell.self), bundle: nil)
    collectionView.register(nib, forCellWithReuseIdentifier: String(describing: HomeCollectionViewCell.self))
    
    let collectionViewLayout = CHTCollectionViewWaterfallLayout()
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(collectionViewLayoutSectionInsetValue,
                                                         collectionViewLayoutSectionInsetValue,
                                                         collectionViewLayoutSectionInsetValue,
                                                         collectionViewLayoutSectionInsetValue)
    collectionView.collectionViewLayout = collectionViewLayout
    
    addPullToRefresh()
    addInfiniteScroll()
  }
  
  private func fetchMovies() {
    DataProvider.sharedInstance.fetchNextMovies(errorClosure: { [weak self] (error) in
      if error != nil {
        if self != nil {
          AlertManager.showError(error!.localizedDescription, viewController: self!)
        }
        return
      }
      
      self?.collectionView.es.stopLoadingMore()
    })
  }
  
  private func setupGradientShadow() {
    let gradient = CAGradientLayer()
    shadowTopView.layoutIfNeeded()
    gradient.frame = shadowTopView.bounds
    gradient.frame.size.width = max(view.bounds.width, view.bounds.height)  // Hack for iPad, in production App an Image would be used. So there would be no need of this hack.
    gradient.colors = [UIColor.gray.withAlphaComponent(0.6).cgColor, UIColor.clear.cgColor]
    shadowTopView.layer.addSublayer(gradient)
  }
  
  private func setupNavigationBar() {
    let navBar = navigationController?.navigationBar
    
    navBar?.tintColor = .white
    navBar?.setBackgroundImage(UIImage(), for: .default)
    navBar?.shadowImage = UIImage()
    navBar?.isTranslucent = true
  }
  
  private func setupOrientationInfo() {
    orientationBeforeTransition = UIDevice.current.orientation
  }
  
  private func addPullToRefresh() {
    collectionView.es.addPullToRefresh { [unowned self] in
      DataProvider.sharedInstance.refreshMovies(errorClosure: { (error) in
        self.collectionView.es.stopPullToRefresh(ignoreDate: true)  // TODO: Show proper alert to user
      })
    }
  }
  
  private func addInfiniteScroll() {
    collectionView.es.addInfiniteScrolling { [unowned self] in
      self.fetchMovies()
    }
  }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController.fetchedObjects?.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HomeCollectionViewCell.self), for: indexPath) as! HomeCollectionViewCell
    cell.movie = fetchedResultsController.object(at: indexPath)
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    currentIndexPath = indexPath
    let selectedItem = fetchedResultsController.object(at: indexPath)
    performSegue(withIdentifier: type(of: self).homeToItemDetailSegue, sender: selectedItem)
  }
}

// MARK: - CHTCollectionViewDelegateWaterfallLayout
extension HomeViewController: CHTCollectionViewDelegateWaterfallLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let padding = CGFloat(25)
    let numberOfColumns = 2
    let effectiveShadownWidth = HomeCollectionViewCell.shadowWidth * CGFloat(numberOfColumns)
    let horizontalInset = collectionViewLayoutSectionInsetValue * CGFloat(numberOfColumns)
    let collectionCellSize = collectionView.frame.size.width - padding - (effectiveShadownWidth + horizontalInset)
    let width = collectionCellSize / CGFloat(numberOfColumns)
    let multiplier: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 0.55 : 1.5  // As per the information provided on TheMovieDB
    let height = (width * multiplier) + HomeCollectionViewCell.detailHeight + HomeCollectionViewCell.verticalPadding // TODO: Discuss with TheMovieDB if we can get this data from API
    return CGSize(width: width, height: height)
  }
}

// MARK: - UINavigationControllerDelegate
extension HomeViewController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if fromVC is ItemDetailViewController || toVC is ItemDetailViewController {
      if UIDevice.current.orientation != orientationBeforeTransition {
        orientationBeforeTransition = UIDevice.current.orientation
        return nil
      }
      
      let scaleTransitionAnimator = ScaleTransitionAnimator()
      scaleTransitionAnimator.isPresenting = operation == .push
      swipePercentDrivenInteractiveTransition.scaleTransitionAnimator = scaleTransitionAnimator
      if swipePercentDrivenInteractiveTransition.isInteractionInProgress { scaleTransitionAnimator.isInteractiveTransition = true }

      return scaleTransitionAnimator
    }

    return nil
  }

  func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if UIDevice.current.orientation != orientationBeforeTransition {
      return nil
    }
    
    return swipePercentDrivenInteractiveTransition.isInteractionInProgress ? swipePercentDrivenInteractiveTransition : nil
  }
}

// MARK: - NSFetchedResultsControllerDelegate
extension HomeViewController: NSFetchedResultsControllerDelegate {
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    collectionView.reloadData()
  }
}

// MARK: - ScaleTransitionProtocol
extension HomeViewController: ScaleTransitionProtocol {
  func snapshotViewForTransition() -> UIView {
    if let cell = collectionView.cellForItem(at: currentIndexPath) as? HomeCollectionViewCell {
      let snapShotView = cell.snapshot()
      let leftUpperPoint = cell.imageView.convert(CGPoint.zero, to: view)
      snapShotView.frame.origin = leftUpperPoint
      return snapShotView
    }
    
    return UIView()
  }
  
  func snapshotViewInitialFrame() -> CGRect {
    if let cell = collectionView.cellForItem(at: currentIndexPath) as? HomeCollectionViewCell {
      let cellOrigin = cell.imageView.convert(CGPoint.zero, to: view)
      return CGRect(origin: cellOrigin, size: cell.imageView.frame.size)
    }
    
    return .zero
  }
}
