//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 16.05.23.
//

import Foundation
import EssentialFeed
import UIKit

public class FeedViewController: UITableViewController
{
    private var loader: FeedLoader?
    
   public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
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
            self.refreshControl?.endRefreshing()
        }
    }
}
