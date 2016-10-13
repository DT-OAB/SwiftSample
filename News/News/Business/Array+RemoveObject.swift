//
//  Array+RemoveObject.swift
//  News
//
//  Created by Brendan GUEGAN on 12/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}
extension Array {
    mutating func removeObject(where predicate: ((Iterator.Element) -> Bool)) {
        if let index = self.index(where: { element -> Bool in
            predicate(element)
        }) {
            self.remove(at: index)
        }
    }
}
