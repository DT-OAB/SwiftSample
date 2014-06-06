//
//  RSSFeedListViewController.m
//  Formation
//
//  Created by Brendan GUEGAN on 06/01/2014.
//  Copyright (c) 2014 IT&L@bs. All rights reserved.
//

#import "RSSFeedViewController.h"
#import "RSSItemViewController.h"
#import "RSSReader.h"

@interface RSSFeedViewController () <RSSReaderDelegate>
{
    NSArray *_rssItems;
    RSSReader *_rssReader;
}
-(void) userDefaultChange:(NSNotification*)notification;

@end

@implementation RSSFeedViewController

@synthesize feed = _feed;

-(void) userDefaultChange:(NSNotification*)notification
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    CGSize itemSize = layout.itemSize;
    itemSize.height = [[NSUserDefaults standardUserDefaults] floatForKey:@"item_height"];
    layout.itemSize = itemSize;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self userDefaultChange:nil];
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultChange:) name:NSUserDefaultsDidChangeNotification object:nil];
}
-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
    [super viewWillDisappear:animated];
}

-(void) setFeed:(RSSFeed *)feed
{
    if(_feed != feed)
    {
        _feed = feed;
        _rssItems = [_feed.items sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"publicationDate" ascending:NO]]];
        [self.collectionView reloadData];
        if(nil != _rssReader)
        {
            _rssReader.delegate = nil;
            _rssReader = nil;
        }
//        self.navigationItem.titleView = self.waitView;
        _rssReader = [[RSSReader alloc] initWithURL:[NSURL URLWithString:_feed.url]];
        // Test avec la délégation
        _rssReader.delegate = self;
        [_rssReader startParsing];
    }
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_rssItems count];
}
-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RSSItemCellIdentifier" forIndexPath:indexPath];
    RSSItem *item = _rssItems[indexPath.row];
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    label.text = item.title;
    label = (UILabel*)[cell viewWithTag:2];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = NSLocalizedString(@"General.DateFormat", @"");
    label.text = [dateFormatter stringFromDate:item.publicationDate];
    label = (UILabel*)[cell viewWithTag:3];
    label.text = item.content;
    return cell;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"pushRSSItem"])
    {
        UICollectionViewCell *cell = (UICollectionViewCell*)sender;
        NSIndexPath *idxPath = [self.collectionView indexPathForCell:cell];
        if(nil != idxPath)
        {
            RSSItemViewController *destinationController = (RSSItemViewController*)segue.destinationViewController;
            destinationController.rssItem = [_rssItems objectAtIndex:idxPath.row];
        }
    }
}

#pragma mark - RSSReaderDelegate protocol implementation
-(void) rssReader:(RSSReader *)reader didFailWithError:(NSError *)error
{
    NSLog(@"error while getting rss feed = %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RSSFeedViewController.GetRSSFeed.Error", @"") message:[error localizedDescription] delegate:self cancelButtonTitle:NSLocalizedString(@"General.Ok", @"") otherButtonTitles:nil];
    [alert show];
}
-(void) rssReader:(RSSReader *)reader didFinishWithFeed:(RSSFeed *)feed
{
    NSLog(@"rss feed = %@", feed);
    self.feed = feed;
    self.navigationItem.titleView = nil != _feed ? nil : self.waitView;
    self.navigationItem.title = _feed.channelTitle;
    _rssItems = [_feed.items sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"publicationDate" ascending:NO]]];
    [self.collectionView reloadData];
}
@end
