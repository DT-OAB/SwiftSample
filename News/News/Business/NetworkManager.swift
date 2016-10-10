//
//  NetworkManager.swift
//  News
//
//  Created by Brendan GUEGAN on 10/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

enum NetworkManagerError: Error {
    case unableToGetURLRequestFromNetworkRequest
    case badHTTPCode(code: Int)
    case nilResponse
    case jsonSerialization(error: Error)
    case network(error: Error)
}

protocol NetworkManagerDelegate {
    func networkManager(_ manager: NetworkManager, didFinishWith json:JSON)
    func networkManager(_ manager: NetworkManager, didFailWith error:Error)
}

protocol NetworkManager {
    var delegate: NetworkManagerDelegate? { get set }
    func perform(request: NetworkRequest) throws 
}
