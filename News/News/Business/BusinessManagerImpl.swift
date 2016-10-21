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
}

