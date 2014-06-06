//
//  RSSItemViewController.h
//  Formation
//
//  Created by Brendan GUEGAN on 06/01/2014.
//  Copyright (c) 2014 IT&L@bs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSItem.h"

@interface RSSItemViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *outletLabelDate;
@property (weak, nonatomic) IBOutlet UIWebView *outletWebViewContent;
@property (weak, nonatomic) IBOutlet UIButton *outletButtonLink;
- (IBAction)onTapLink:(id)sender;

@property (nonatomic, strong) RSSItem *rssItem;

@end
