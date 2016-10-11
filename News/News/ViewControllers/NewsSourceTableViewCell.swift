//
//  NewsSourceTableViewCell.swift
//  News
//
//  Created by Brendan GUEGAN on 11/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import UIKit

class NewsSourceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var category: UILabel!
    
    var newsSource: NewsSource? {
        didSet {
            update()
        }
    }
    
    private func update() {
        title?.text = newsSource?.name
        category?.text = newsSource?.category.rawValue
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
