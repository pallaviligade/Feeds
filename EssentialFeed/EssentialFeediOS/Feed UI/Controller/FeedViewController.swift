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
    private var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    
    public convenience init(feedloader: FeedLoader, imageLoader:  FeedImageDataLoader) {
        self.init()
        self.refershViewController = FeedRefershViewController(feedload: feedloader)
        refershViewController?.onClick = { [weak self] feed in
            self?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refershViewController?.view
       
        tableView.prefetchDataSource = self
        refershViewController?.refresh()
    }
    
  
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       cancelCellControllerLoads(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoads)
        
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoads(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
