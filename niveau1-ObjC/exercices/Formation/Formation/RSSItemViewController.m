//
//  RSSItemViewController.m
//  Formation
//
//  Created by Brendan GUEGAN on 06/01/2014.
//  Copyright (c) 2014 IT&L@bs. All rights reserved.
//

#import "RSSItemViewController.h"

@interface RSSItemViewController ()
-(void) updateView;
@end

@implementation RSSItemViewController
@synthesize rssItem = _rssItem;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateView];
}

-(void) setRssItem:(RSSItem *)rssItem
{
    if(_rssItem != rssItem)
    {
        _rssItem = rssItem;
        [self updateView];
    }
}

- (IBAction)onTapLink:(id)sender
{
    if(nil != _rssItem.link && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:_rssItem.link]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_rssItem.link]];
    }
}

-(void) updateView
{
    _outletButtonLink.hidden = nil==_rssItem;
    if(nil != _rssItem)
    {
        self.navigationItem.title = _rssItem.title;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = NSLocalizedString(@"General.DateFormat", @"");
        _outletLabelDate.text = [dateFormatter stringFromDate:_rssItem.publicationDate];
        [_outletWebViewContent loadHTMLString:_rssItem.content baseURL:nil];
    }
    else
    {
        _outletLabelDate.text = nil;
        [_outletWebViewContent loadHTMLString:nil baseURL:nil];
        self.navigationItem.title = nil;
    }
}
@end
