//
//  NewsSourceArticleTableViewCell.swift
//  News
//
//  Created by Brendan GUEGAN on 11/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import UIKit

class NewsSourceArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var article: Article? {
        didSet {
            update()
        }
    }
    
    private func update() {
        if let article = article {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "'le' dd/MM/yyyy 'à' HH'h'mm"
            dateLabel?.text = dateFormatter.string(from: article.publicationDate)
            titleLabel?.text = article.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }

}
