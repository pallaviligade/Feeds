//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 16.05.23.
//

import Foundation
import EssentialFeed
import UIKit



public final  class FeedViewController: UITableViewController,UITableViewDataSourcePrefetching
{
    private var refershViewController: FeedRefershViewController?
    private var tableModel = [FeedImage]() {
        didSet { tableView.reloadData() }
    }
    private var imageLoder: FeedImageDataLoader?
    
    private(set) var tasks = [IndexPath: FeedImageDataLoaderTask]()
    private(set) var tasks1 = [IndexPath: String]()
    
    public convenience init(feedloader: FeedLoader, imageLoader:  FeedImageDataLoader) {
        self.init()
        self.refershViewController = FeedRefershViewController(feedload: feedloader)
        self.imageLoder = imageLoader
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refershViewController?.view
        refershViewController?.onClick = { [weak self] feed in
            self?.tableModel = feed
        }
        tableView.prefetchDataSource = self
        refershViewController?.refresh()
    }
    
  
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel  = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location) ==  nil
        cell.discrptionLabel.text = cellModel.description
        cell.locationLabel.text = cellModel.location
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
       
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.tasks1[indexPath] = "Pallav"
            print(tasks1)
            self.tasks[indexPath] = self.imageLoder?.loadImageData(from: cellModel.imageURL) { [weak cell] result in
                let imageData = try? result.get()
                let image = imageData.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cell = tableModel[indexPath.row]
             tasks[indexPath] = imageLoder?.loadImageData(from: cell.imageURL, completionHandler: { _ in })
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            tasks[indexPath]?.cancel()
            tasks[indexPath] = nil
        }
        
    }
}
