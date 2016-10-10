//
//  NetworkManagerImpl.swift
//  News
//
//  Created by Brendan GUEGAN on 10/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation

class NetworkManagerImpl: NSObject, NetworkManager {
    
    var delegate: NetworkManagerDelegate?
    
    private lazy var session: URLSession = {
        var configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue())
    }()
    
    func perform(request: NetworkRequest) throws {
        guard let urlRequest = request.urlRequest else {
            throw NetworkManagerError.unableToGetURLRequestFromNetworkRequest
        }
        let task = self.session.dataTask(with: urlRequest) {[weak self] (data, response, error) in
            var finalError: Error?
            var json: JSON?
            defer {
                if let sself = self {
                    if let finalError = finalError {
                        sself.delegate?.networkManager(sself, didFailWith: finalError)
                    }
                    else if let json = json {
                        sself.delegate?.networkManager(sself, didFinishWith: json)
                    }
                }
            }
            if let error = error {
                finalError = NetworkManagerError.network(error: error)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let data = data {
                        do {
                            json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? JSON
                        }
                        catch {
                            finalError = NetworkManagerError.jsonSerialization(error: error)
                        }
                        return
                    }
                    finalError = NetworkManagerError.nilResponse
                default:
                    finalError = NetworkManagerError.badHTTPCode(code: httpResponse.statusCode)
                }
            }
        }
        task.resume()
    }
}
