//
//  NewsSourceTableViewController.swift
//  News
//
//  Created by Brendan GUEGAN on 11/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation
import UIKit

class NewsSourceTableViewController: UITableViewController {
    
    var manager: BusinessManager? {
        didSet {
            manager?.getSources(for: .english, category: .business, country: .usa) { [weak self] sources, error in
                guard let sself = self else { return }
                if let error = error {
                    print("Error while getting sources: \(error)")
                }
                DispatchQueue.main.sync {
                    sself.newsSources.removeAll()
                    if let sources = sources {
                        sself.newsSources.append(contentsOf: sources)
                    }
                    if sself.isViewLoaded {
                        sself.tableView.reloadData()
                    }
                }
            }
        }
    }
    var newsSources = [NewsSource]()
}

extension NewsSourceTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsSources.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsSourceCellIdentifier", for: indexPath)
        if let cell = cell as? NewsSourceTableViewCell {
            cell.newsSource = newsSources[indexPath.row]
        }
        return cell
    }
}
