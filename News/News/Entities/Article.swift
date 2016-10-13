//
//  NewsElement.swift
//  News
//
//  Created by Brendan GUEGAN on 10/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation

struct Article: JSONDecodable {
    
    let author: String
    let title: String
    let description: String
    let url: URL
    let image: URL
    let publicationDate: Date
    
    init?(from json: JSON) {
        func parseUrl(from json: JSON, with key: String) -> URL? {
            guard let urlString = json[key] as? String else { return nil }
            return URL(string: urlString)
        }
        guard let author = json[Article.kAuthor] as? String else { return nil }
        self.author = author
        guard let description = json[Article.kDescription] as? String else { return nil }
        self.description = description
        guard let title = json[Article.kTitle] as? String else { return nil }
        self.title = title
        guard let url = parseUrl(from: json, with: Article.kUrl) else { return nil }
        self.url = url
        guard let imageUrl = parseUrl(from: json, with: Article.kImageUrl) else { return nil }
        self.image = imageUrl
        guard let date = json[Article.kPublicationDate] as? String else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        guard let pubDate = dateFormatter.date(from: date) else { return nil }
        self.publicationDate = pubDate
    }
    
    private static let kAuthor = "author"
    private static let kDescription = "description"
    private static let kTitle = "title"
    private static let kUrl = "url"
    private static let kImageUrl = "urlToImage"
    private static let kPublicationDate = "publishedAt"
    
}
