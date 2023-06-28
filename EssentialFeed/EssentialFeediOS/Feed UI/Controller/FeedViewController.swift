//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 16.05.23.
//

import Foundation
import UIKit

protocol FeedViewControllerDelegate {
    func didRefershFeedRequest()
}


public final  class FeedViewController: UITableViewController,UITableViewDataSourcePrefetching, FeedloadingView
{
     var delegate: FeedViewControllerDelegate?
     var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
  
    public override func viewDidLoad() {
        super.viewDidLoad()
       
        tableView.prefetchDataSource = self
        refresh()
    }
    
    @IBAction func refresh()
    {
        delegate?.didRefershFeedRequest()
        
    }
    func display(_ viewModel: FeedloadingViewModel) {
        if viewModel.isloading {
            refreshControl?.beginRefreshing()
        }else {
            refreshControl?.endRefreshing()
        }
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
