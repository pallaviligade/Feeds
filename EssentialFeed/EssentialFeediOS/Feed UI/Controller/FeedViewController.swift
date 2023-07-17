//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 16.05.23.
//

import UIKit
import EssentialFeed

protocol FeedViewControllerDelegate {
    func didRefershFeedRequest()
}


public final  class FeedViewController: UITableViewController,UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView
{
     var delegate: FeedViewControllerDelegate?
    @IBOutlet private(set) public var errorView: ErrorView?
     var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
  
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = FeedPresenter.title
        refresh()
    }
    
    @IBAction func refresh()
    {
        delegate?.didRefershFeedRequest()
        
    }
    
    public func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        }else {
            refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ viewModel: FeedErrorViewModel) {
        if let message = viewModel.message {
            errorView?.show(message: message)
        } else {
            errorView?.hideMessage()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(at: tableView)
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
