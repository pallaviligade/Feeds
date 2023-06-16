//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 07.06.23.
//

import Foundation
import UIKit




final class FeedRefershViewController: NSObject, FeedloadingView {
    
    
   private(set) lazy var view = loadView()
  
    
    private  let presenter:  FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
 
    
    @objc func refresh()
    {
        presenter.loadFeed()
        
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
