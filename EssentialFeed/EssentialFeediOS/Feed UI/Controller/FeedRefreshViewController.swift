//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 07.06.23.
//

import Foundation
import UIKit




final class FeedRefershViewController: NSObject {
    
   private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
  
    
    private  let feedViewModel:  FeedViewModel
    
    init(feedViewModel: FeedViewModel) {
        self.feedViewModel = feedViewModel
    }
    
 
    
    @objc func refresh()
    {
        feedViewModel.loadFeed()
        
    }
    
   private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
       feedViewModel.onloadingStateChage =   { [weak view]  isLoading in

           if isLoading {
               view?.beginRefreshing()
           }else {
               view?.endRefreshing()
           }
         
       }
       view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        // This binding logic between view model and view
       return view
    }
}
