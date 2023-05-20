//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 16.05.23.
//

import Foundation
import EssentialFeed
import UIKit

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL)
    func cancelImageDataLoader(from url: URL)
}

public class FeedViewController: UITableViewController
{
    private var loader: FeedLoader?
    private var tableModel = [FeedImage]()
    private var imageLoder: FeedImageDataLoader?
    
    public convenience init(loader: FeedLoader, imageLoader:  FeedImageDataLoader) {
        self.init()
        self.loader = loader
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
        loader?.load{ [weak self] result in
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
        imageLoder?.loadImageData(from: cellModel.imageURL)
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        imageLoder?.cancelImageDataLoader(from: cellModel.imageURL)
    }
}
