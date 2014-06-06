//
//  RSSReader.h
//  Formation
//
//  Created by Brendan GUEGAN on 02/02/12.
//  Copyright (c) 2012 IT&L@bs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSFeed;
@class RSSReader;

@protocol RSSReaderDelegate <NSObject>

-(void) rssReader:(RSSReader*)reader didFinishWithFeed:(RSSFeed*)feed;
-(void) rssReader:(RSSReader*)reader didFailWithError:(NSError*)error;

@end

extern NSString * const RSSReaderParsingDidFinishNotification;
extern NSString * const kRSSReaderParsingDidFinishNotificationFeed;


/*!
 Instances of this class parse RSS feed asynchronously from a file or a distant url.
 */
@interface RSSReader : NSObject
{
}

/*! 
 The reference to the read rss feed.
 */
@property (strong, readonly) RSSFeed *feed;

@property (weak) id<RSSReaderDelegate> delegate;

-(instancetype) initWithURL:(NSURL*)url;
-(void) startParsing;
-(void) startParsingWithCompletion:(void (^)(RSSFeed *feed, NSError *error))completionBlock;

@end
