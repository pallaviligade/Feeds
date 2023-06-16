//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 07.06.23.
//

import Foundation
import UIKit


protocol FeedRefershViewControllerDelegate {
    func didRefershFeedRequest()
}

final class FeedRefershViewController: NSObject, FeedloadingView {
    
    
   private(set) lazy var view = loadView()
  
    
    private  let delegate:  FeedRefershViewControllerDelegate
    
    init(delegate:FeedRefershViewControllerDelegate) {
        self.delegate =  delegate
    }
    
 
    
    @objc func refresh()
    {
        delegate.didRefershFeedRequest()
        
    }
   
    
    func display(_ viewModel: FeedloadingViewModel) {
        if viewModel.isloading {
            view.beginRefreshing()
        }else {
            view.endRefreshing()
        }
    }
    
   private func loadView() -> UIRefreshControl {
       let view = UIRefreshControl()
       view.addTarget(self, action: #selector(refresh), for: .valueChanged)
       return view
    }
}
