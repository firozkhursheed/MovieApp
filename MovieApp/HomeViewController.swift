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
  let swipePercentDrivenInteractiveTransition = SwipePercentDrivenInteractiveTransition()

  // MARK: - IBOutlet
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var shadowTopView: UIView!
  
  // MARK: - Variables
  var currentIndexPath: IndexPath!
  
  lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
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
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if segue.identifier == "homeToItemDetailSegue" {
      navigationController?.delegate = self
      let itemDetailViewController = segue.destination as! ItemDetailViewController
      itemDetailViewController.movie = sender as! Movie
      swipePercentDrivenInteractiveTransition.wireTo(viewController: itemDetailViewController)
    }
  }
  
  override func snapshotViewForTransition() -> UIView {
    if let cell = collectionView.cellForItem(at: currentIndexPath) as? HomeCollectionViewCell {
      let snapShotView = cell.snapshot()
      let leftUpperPoint = cell.imageView.convert(CGPoint.zero, to: view)
      snapShotView.frame.origin = leftUpperPoint
      return snapShotView
    }
    
    return UIView()
  }
  
  override func snapshotViewInitialFrame() -> CGRect {
    if let cell = collectionView.cellForItem(at: currentIndexPath) as? HomeCollectionViewCell {
      let cellOrigin = cell.imageView.convert(CGPoint.zero, to: view)
      return CGRect(origin: cellOrigin, size: cell.imageView.frame.size)
    }
    
    return .zero
  }
  
  // MARK: - Private Methods
  private func setupCollectionView() {
    let nib = UINib(nibName: "HomeCollectionViewCell", bundle: nil)
    collectionView.register(nib, forCellWithReuseIdentifier: "HomeCollectionViewCell")
    
    let collectionViewLayout = CHTCollectionViewWaterfallLayout()
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
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
    gradient.frame = shadowTopView.bounds
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
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
    cell.movie = fetchedResultsController.object(at: indexPath)
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    currentIndexPath = indexPath
    let selectedItem = fetchedResultsController.object(at: indexPath)
    performSegue(withIdentifier: "homeToItemDetailSegue", sender: selectedItem)
  }
}

// MARK: - CHTCollectionViewDelegateWaterfallLayout
extension HomeViewController: CHTCollectionViewDelegateWaterfallLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let padding: CGFloat = 25
    let collectionCellSize = collectionView.frame.size.width - padding - (8 + 20)
    let width = collectionCellSize / 2
    let height = (width * 1.5) + HomeCollectionViewCell.detailHeight + HomeCollectionViewCell.verticalPadding // TODO: Discuss with TheMovieDB if we can get this data from API
    return CGSize(width: width, height: height)
  }
}

// MARK: - UINavigationControllerDelegate
extension HomeViewController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if fromVC is ItemDetailViewController || toVC is ItemDetailViewController {
      let homeToItemDetailTransitionAnimator = HomeToItemDetailTransitionAnimator()
      homeToItemDetailTransitionAnimator.isPresenting = operation == .push
      swipePercentDrivenInteractiveTransition.homeToItemDetailTransitionAnimator = homeToItemDetailTransitionAnimator
      if swipePercentDrivenInteractiveTransition.isInteractionInProgress { homeToItemDetailTransitionAnimator.isInteractiveTransition = true }

      return homeToItemDetailTransitionAnimator
    }

    return nil
  }

  func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return swipePercentDrivenInteractiveTransition.isInteractionInProgress ? swipePercentDrivenInteractiveTransition : nil
  }
}

// MARK: - NSFetchedResultsControllerDelegate
extension HomeViewController: NSFetchedResultsControllerDelegate {
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    collectionView.reloadData()
  }
}
