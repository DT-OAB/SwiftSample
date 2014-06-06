//
//  RSSFeedListViewController.h
//  Formation
//
//  Created by Brendan GUEGAN on 06/01/2014.
//  Copyright (c) 2014 IT&L@bs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSFeed.h"

@interface RSSFeedViewController : UICollectionViewController
@property (weak, nonatomic) IBOutlet UIView *waitView;

@property (nonatomic, strong) RSSFeed *feed;
@end
