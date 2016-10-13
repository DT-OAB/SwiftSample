//
//  BusinessManagerImpl+NetworkManagerDelegate.swift
//  News
//
//  Created by Brendan GUEGAN on 12/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation

extension BusinessManagerImpl: NetworkManagerDelegate {
    
    private func parse<T: JSONDecodable>(json: JSON, key: String) -> [T] {
        var result = [T]()
        if let jsonSources = json[key] as? [JSON] {
            result = jsonSources.flatMap { T(from: $0) }
        }
        return result
    }
    
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
            let sources: [NewsSource] = parse(json: json, key: "sources")
            handler(sources, nil)
            return
        }
        if let handler = articlesHandler {
            let articles = parse(json: json, key: "articles") as [Article]
            handler(articles, nil)
            return
        }
    }
}
