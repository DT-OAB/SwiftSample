//
//  RSSFeed.swift
//  Formation
//
//  Created by Brendan GUEGAN on 06/06/2014.
//  Copyright (c) 2014 IT&L@bs. All rights reserved.
//

import UIKit

class RSSFeed: NSObject
{
    var title: NSString
    var items: Array<RSSItem>
    
    init(title: NSString)
    {
        self.title = title;
        items = [];
        super.init();
    }
    convenience init()
    {
        self.init(title: "")
    }
    
    func addItem(item: RSSItem)
    {
        items += item;
    }
    
    func removeItemAtIndex(index: Int)
    {
        items.removeAtIndex(index);
    }
    
    func addItem(item: RSSItem, index: Int)
    {
        items.insert(item, atIndex:index);
    }
    
    func removeAllItems()
    {
        items.removeAll(keepCapacity: false);
    }
    
    func description() -> String
    {
        return "Feed = \(title) \n items = \(items)"
    }
}
