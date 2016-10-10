//
//  NewsSource.swift
//  News
//
//  Created by Brendan GUEGAN on 10/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation

struct NewsSource {
    
    enum LogoType: String {
        case small = "small"
        case medium = "medium"
        case large = "large"
    }
    
    let identifier: String
    let name: String
    let description: String
    let url: URL
    let category: String
    let language: String
    let country: String
    var logos = [LogoType: URL]()
    
    var articles = [Article]()
    
    mutating func add(logoWith type: LogoType, url: URL?) {
        logos[type] = url
    }
    mutating func remove(logoWith type: LogoType) {
        logos[type] = nil
    }
    
    mutating func add(article: Article) {
        articles.append(article)
    }
    mutating func remove(article: Article) {
        if let idx = articles.index(where: {$0.url == article.url }) {
            articles.remove(at: idx)
        }
    }
    mutating func removeAllArticles() {
        articles.removeAll()
    }
}
