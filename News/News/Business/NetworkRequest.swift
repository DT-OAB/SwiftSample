//
//  NetworkRequest.swift
//  News
//
//  Created by Brendan GUEGAN on 10/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation

enum NetworkRequest {
    
    private static let baseURL = "https://newsapi.org/"
    private static let apiKey = "2c64fe5d063645f58a5cd563308d0e7c"
    
    enum SortBy: String {
        case top = "top"
        case latest = "latest"
        case popular = "popular"
    }
    
    case sources(language: NewsSource.SourceLanguage, category: NewsSource.SourceCategory, country: NewsSource.SourceCountry)
    case articles(source: String, sortBy: SortBy)
    
    var method: String {
        switch self {
        case .sources:
            return "GET"
        default:
            return "GET"
        }
    }
    
    var urlRequest: URLRequest? {
        guard var components = URLComponents(string: NetworkRequest.baseURL) else {
            return nil
        }
        var query = [String]()
        switch self {
        case .sources(let language, let category, let country):
            query.append("language=\(language.rawValue)")
            query.append("category=\(category.rawValue)")
            query.append("country=\(country.rawValue)")
            components.path = "/v1/sources"
            break
        case .articles(let source, let sortBy):
            query.append("source=\(source)")
            query.append("sortBy=\(sortBy.rawValue)")
            components.path = "/v1/articles"
        }
        query.append("apiKey=\(NetworkRequest.apiKey)")
        components.query = query.joined(separator: "&")
        guard let url = components.url else {
            return nil
        }
        var result = URLRequest(url: url)
        result.httpMethod = self.method
        return result
    }
}
