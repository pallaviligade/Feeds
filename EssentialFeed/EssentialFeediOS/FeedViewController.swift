//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 16.05.23.
//

import Foundation
import EssentialFeed
import UIKit

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result <Data, Error>
    func loadImageData(from url: URL,  completionHandler:@escaping (Result) ->  Void ) -> FeedImageDataLoaderTask
}

public final  class FeedViewController: UITableViewController
{
    private var feedloader: FeedLoader?
    private var tableModel = [FeedImage]()
    private var imageLoder: FeedImageDataLoader?
    
    private(set) var tasks = [IndexPath: FeedImageDataLoaderTask]()
    
    public convenience init(feedloader: FeedLoader, imageLoader:  FeedImageDataLoader) {
        self.init()
        self.feedloader = feedloader
        self.imageLoder = imageLoader
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
   @objc func load()
    {
        refreshControl?.beginRefreshing()
        feedloader?.load{ [weak self] result in
           guard let self = self else { return }
            if let feed  = try? result.get()  {
                self.tableModel = feed
                self.tableView.reloadData()
            }           
            self.refreshControl?.endRefreshing()
        }
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
        cell.feedImageContainer.startShimmering()
        tasks[indexPath] = imageLoder?.loadImageData(from: cellModel.imageURL) { [weak cell] result in
            let imageData = try? result.get()
            cell?.feedImageView.image = imageData.map(UIImage.init) ?? nil
            cell?.feedImageContainer.stopShimmering()
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
