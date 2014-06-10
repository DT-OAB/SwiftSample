//
//  RSSReader.swift
//  Formation
//
//  Created by Brendan GUEGAN on 06/06/2014.
//  Copyright (c) 2014 IT&L@bs. All rights reserved.
//

import UIKit

protocol RSSReaderDelegate: NSObjectProtocol
{
    func rssReaderParsingDidFinish(rssReader: RSSReader)
    func rssReaderParsingDidFail(rssReader: RSSReader, error: NSError)
}

let kRSSItemItemTag: String         = "item"
let kRSSItemTitleTag: String        = "title"
let kRSSItemLinkTag: String         = "link"
let kRSSItemDateTag: String         = "pubDate"
let kRSSItemContentTag: String      = "content:encoded"

class RSSReader: NSObject, NSXMLParserDelegate
{
    var data: NSMutableData? = nil
    var feed: RSSFeed?
    var item: RSSItem?
    let url: NSURL
    let session: NSURLSession
    var delegate:RSSReaderDelegate?
    var isItem: Bool
    var stringBuffer: String
    
    init(url url_: NSURL!)
    {
        url = url_
        let configuration:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: configuration);
        isItem = false
        stringBuffer = ""
        super.init();
    }
    
    func startParsing()
    {
        if nil == url
        {
            return
        }
        let task: NSURLSessionDataTask = session.dataTaskWithURL(url, completionHandler: {data, response, error in
            let statusOK = 200
            let httpResponse = response as? NSHTTPURLResponse
            if nil != data && nil != httpResponse && statusOK == httpResponse?.statusCode
            {
                let xmlParser:NSXMLParser = NSXMLParser(data: data);
                xmlParser.delegate = self
                if false == xmlParser.parse()
                {
                    println("parsing failed with error : \(xmlParser.parserError)")
                    if nil != self.delegate
                    {
                        self.delegate?.rssReaderParsingDidFail(self, error: error)
                    }
                    return
                }
                if nil != self.delegate
                {
                    self.delegate?.rssReaderParsingDidFinish(self)
                }
                return
            }
            if nil != error
            {
                println("error : \(error)")
                if nil != self.delegate
                {
                    self.delegate?.rssReaderParsingDidFail(self, error: error)
                }
                return
            }
            println("data is nil or response is not an http response")
            })
        task.resume()
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: NSDictionary!)
    {
        stringBuffer = ""
        switch elementName
            {
        case kRSSItemTitleTag:
            if !isItem
            {
                feed = RSSFeed()
            }
        case kRSSItemItemTag:
            item = RSSItem()
            feed!.addItem(item!)
            isItem = true
        default:
            return
        }
    }
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        
        switch elementName
            {
        case kRSSItemTitleTag:
            if !isItem
            {
                feed!.title = stringBuffer
            }
            else
            {
                item!.title = stringBuffer
            }
        case kRSSItemDateTag :
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            item!.date = dateFormatter.dateFromString(stringBuffer)
        case kRSSItemLinkTag:
            if isItem
            {
                item!.linkURL = NSURL(string: stringBuffer)
            }
        case kRSSItemContentTag:
            item!.linkURL = NSURL(string: stringBuffer)
        case kRSSItemItemTag:
            item = nil
            isItem = false
        default:
            stringBuffer = ""
            return
        }
        stringBuffer = ""
    }
    func parser(parser: NSXMLParser!, foundCharacters string: String!)
    {
        stringBuffer += string
    }
    func parser(parser: NSXMLParser!, foundCDATA CDATABlock: NSData!)
    {
        stringBuffer += NSString(data: CDATABlock, encoding: NSUTF8StringEncoding)
    }

}
