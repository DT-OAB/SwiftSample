//
//  JSONDecodable.swift
//  News
//
//  Created by Brendan GUEGAN on 12/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation

protocol JSONDecodable {
    init?(from json: JSON)
}
