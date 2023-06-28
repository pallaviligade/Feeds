//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 17.05.23.
//

import UIKit

public final class FeedImageCell: UITableViewCell {

    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var discrptionLabel: UILabel!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
   
   
    
   
    var  onRetry: (() -> Void)?
    
    @IBAction func retryButtonTapped(){
        onRetry?()
    }
}
