//
//  NewsSource.swift
//  News
//
//  Created by Brendan GUEGAN on 10/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation

struct NewsSource: JSONDecodable {
    
    enum LogoType: String {
        case small = "small"
        case medium = "medium"
        case large = "large"
    }
    enum SourceCategory: String {
        case business = "business"
        case entertainment = "latest"
        case gaming = "gaming"
        case general = "general"
        case music = "music"
        case scienceAndNature = "science-and-nature"
        case sport = "sport"
        case technology = "technology"
    }
    enum SourceCountry: String {
        case australia = "au"
        case germany = "de"
        case unitedKingdom = "gb"
        case india = "in"
        case italy = "it"
        case usa = "us"
    }
    enum SourceLanguage: String {
        case english = "en"
        case french = "fr"
        case german = "de"
    }
    
    let identifier: String
    let name: String
    let description: String
    let url: URL
    let category: SourceCategory
    let language: SourceLanguage
    let country: SourceCountry
    var logos = [LogoType: URL]()
    /// Voici un tableau d'articles
    var articles = [Article]()
    
    mutating func add(logoWith type: LogoType, url: URL?) {
        logos[type] = url
    }
    mutating func remove(logoWith type: LogoType) {
        logos[type] = nil
    }
    
    /// Voici ce que fait ma méthode
    ///
    /// - parameter article: Voici à quoi sert ce paramètre
    mutating func add(article: Article) {
        articles.append(article)
    }
    mutating func remove(article: Article) {
        let filtered = articles.filter { $0.author.hasPrefix("John") }.count > 0
        articles.removeObject { $0.url == article.url }
//        articles.removeObject(object: article)
    }
    mutating func removeAllArticles() {
        articles.removeAll()
    }
    
    init?(from json: JSON) {
        guard let identifier = json[NewsSource.kId] as? String else { return nil }
        self.identifier = identifier
        guard let name = json[NewsSource.kName] as? String else { return nil }
        self.name = name
        guard let description = json[NewsSource.kDescription] as? String else { return nil }
        self.description = description
        guard let urlString = json[NewsSource.kUrl] as? String else { return nil }
        guard let url = URL(string: urlString) else { return nil }
        self.url = url
        guard let categoryString = json[NewsSource.kCategory] as? String else { return nil }
        guard let category = SourceCategory(rawValue: categoryString) else { return nil }
        self.category = category
        guard let languageString = json[NewsSource.kLanguage] as? String else { return nil }
        guard let language = SourceLanguage(rawValue: languageString) else { return nil }
        self.language = language
        guard let countryString = json[NewsSource.kCountry] as? String else { return nil }
        guard let country = SourceCountry(rawValue: countryString) else { return nil }
        self.country = country
        guard let logosDict = json[NewsSource.kLogos] as? [String: String] else { return nil }
        for (key, value) in logosDict {
            if let logo = LogoType(rawValue: key), let logoUrl = URL(string: value) {
                logos[logo] = logoUrl
            }
        }
    }
    
    private static let kId = "id"
    private static let kName = "name"
    private static let kDescription = "description"
    private static let kUrl = "url"
    private static let kCategory = "category"
    private static let kLanguage = "language"
    private static let kCountry = "country"
    private static let kLogos = "urlsToLogos"
}
