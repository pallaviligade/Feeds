//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 17.05.23.
//

import UIKit

public final class FeedImageCell: UITableViewCell {

   public let locationContainer = UIView()
   public let discrptionLabel = UILabel()
   public let locationLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
   
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
   
    var  onRetry: (() -> Void)?
    @objc func retryButtonTapped(){
        onRetry?()
    }
}
