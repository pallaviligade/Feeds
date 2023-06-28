//
//  TableView+Deque.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 28.06.23.
//

import UIKit
extension UITableView {
    func dequeReuableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
