//
//  RSSItem.h
//  Formation
//
//  Created by Brendan GUEGAN on 06/01/2014.
//  Copyright (c) 2014 IT&L@bs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RSSFeed;

@interface RSSItem : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * publicationDate;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) RSSFeed *feed;

@end
