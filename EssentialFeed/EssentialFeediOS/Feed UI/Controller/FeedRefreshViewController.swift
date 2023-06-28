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
    
    
    @IBOutlet private var view: UIRefreshControl?
  
    
    var delegate:  FeedRefershViewControllerDelegate?

    
    @IBAction func refresh()
    {
        delegate?.didRefershFeedRequest()
        
    }
   
    
    func display(_ viewModel: FeedloadingViewModel) {
        if viewModel.isloading {
            view?.beginRefreshing()
        }else {
            view?.endRefreshing()
        }
    }
    
  
}
