//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 07.06.23.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedRefershViewController: NSObject {
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private  let feedloader:  FeedLoader
    
    init(feedload: FeedLoader) {
        self.feedloader = feedload
    }
    
    public var onClick: (([FeedImage])-> Void)?
    
    @objc func refresh()
     {
         view.beginRefreshing()
         feedloader.load{ [weak self] result in
            guard let self = self else { return }
             if let feed  = try? result.get()  {
                 onClick?(feed)
             }
             view.endRefreshing()
         }
     }
}
