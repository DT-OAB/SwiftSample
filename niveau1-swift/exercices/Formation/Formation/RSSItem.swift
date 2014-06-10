//
//  RSSItem.swift
//  Formation
//
//  Created by Brendan GUEGAN on 06/06/2014.
//  Copyright (c) 2014 IT&L@bs. All rights reserved.
//

import UIKit

class RSSItem: NSObject
{
    var title: NSString
    var date: NSDate
    var content: NSString
    var linkURL: NSURL
    
    init(title title_: NSString, date date_: NSDate, content content_: NSString, linkURL linkURL_: NSURL)
    {
        self.date = date_;
        self.content = content_;
        self.linkURL = linkURL_;
        self.title = title_
//        super.init();
    }
    
    convenience init() {
        let url: NSURL = NSURL()
        self.init(title:"", date: NSDate(), content: "", linkURL: url)
    }
    
    func description() -> String
    {
        return "title:\(title), date:\(date)\n"
    }
}
