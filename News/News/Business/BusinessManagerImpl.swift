//
//  BusinessManagerImpl.swift
//  News
//
//  Created by Brendan GUEGAN on 10/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation

class BusinessManagerImpl: BusinessManager {
    
    private let networkManager: NetworkManager
    private(set) internal var sourcesHandler: (([NewsSource]?, Error?) -> Void)?
    private(set) internal var articlesHandler: (([Article]?, Error?) -> Void)?
    
    init() {
        networkManager = NetworkManagerImpl()
        networkManager.delegate = self
    }
    
    func getSources(for language: NewsSource.SourceLanguage, category: NewsSource.SourceCategory, country: NewsSource.SourceCountry, with completionHandler: @escaping ([NewsSource]?, Error?) -> Void) {
        sourcesHandler = completionHandler
        articlesHandler = nil
        let request = NetworkRequest.sources(language: language, category: category, country: country)
        do {
            try networkManager.perform(request: request)
        }
        catch {
            completionHandler(nil, error)
        }
    }
    func getArticles(for source: NewsSource, sorted by: NetworkRequest.SortBy, with completionHandler: @escaping ([Article]?, Error?) -> Void) {
        articlesHandler = completionHandler
        sourcesHandler = nil
        let request = NetworkRequest.articles(source: source.identifier, sortBy: by)
        do {
            try networkManager.perform(request: request)
        }
        catch {
            completionHandler(nil, error)
        }
    }
}

extension BusinessManagerImpl: NetworkManagerDelegate {
    func networkManager(_ manager: NetworkManager, didFailWith error: Error) {
        if let handler = sourcesHandler {
            handler(nil, error)
            return
        }
        if let handler = articlesHandler {
            handler(nil, error)
            return
        }
    }
    func networkManager(_ manager: NetworkManager, didFinishWith json: JSON) {
        if let handler = sourcesHandler {
            var sources = [NewsSource]()
            if let jsonSources = json["sources"] as? [JSON] {
                for aJSON in jsonSources {
                    if let aSource = NewsSource(from: aJSON) {
                        sources.append(aSource)
                    }
                }
            }
            handler(sources, nil)
            return
        }
        if let handler = articlesHandler {
            var articles = [Article]()
            if let jsonArticles = json["articles"] as? [JSON] {
                for aJSON in jsonArticles {
                    if let anArticle = Article(from: aJSON) {
                        articles.append(anArticle)
                    }
                }
            }
            handler(articles, nil)
            return
        }
    }
}
