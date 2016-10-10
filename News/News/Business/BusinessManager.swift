//
//  BusinessManager.swift
//  News
//
//  Created by Brendan GUEGAN on 10/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation

protocol BusinessManager {
    func getSources(for language: NewsSource.SourceLanguage, category: NewsSource.SourceCategory, country: NewsSource.SourceCountry, with completionHandler: @escaping ([NewsSource]?, Error?) -> Void)
    func getArticles(for source: NewsSource, sorted by: NetworkRequest.SortBy, with completionHandler: @escaping ([Article]?, Error?) -> Void)
}
