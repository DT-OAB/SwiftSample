//
//  RSSFeed.h
//  Formation
//
//  Created by Brendan GUEGAN on 06/01/2014.
//  Copyright (c) 2014 IT&L@bs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RSSItem;

@interface RSSFeed : NSManagedObject

@property (nonatomic, retain) NSString * channelTitle;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *items;
@end

@interface RSSFeed (CoreDataGeneratedAccessors)

- (void)addItemsObject:(RSSItem *)value;
- (void)removeItemsObject:(RSSItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
