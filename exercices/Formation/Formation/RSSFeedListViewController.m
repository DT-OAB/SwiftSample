//
//  RSSFeedListViewController.m
//  Formation
//
//  Created by Brendan GUEGAN on 06/01/2014.
//  Copyright (c) 2014 IT&L@bs. All rights reserved.
//

#import "RSSFeedListViewController.h"
#import "RSSFeed.h"
#import "AppDelegate.h"
#import "RSSFeedViewController.h"

@interface RSSFeedListViewController () <UIAlertViewDelegate>
{
    NSMutableArray *_feeds;
}

@end

@implementation RSSFeedListViewController

-(NSManagedObjectContext*) context
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    return appDelegate.managedObjectContext;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"RSSFeedListViewController.NavigationItem.Title", @"");
    if(nil == _feeds)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"RSSFeed"];
        NSError *error = nil;
        NSArray *result = [[self context] executeFetchRequest:request error:&error];
        if(nil == result)
        {
            NSLog(@"Error while getting feed list = %@", error);
        }
        else
        {
            _feeds = [[NSMutableArray alloc] initWithArray:result];
        }
    }
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _feeds = nil;
}

- (IBAction)onTapAddNewFeed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RSSFeedListViewController.AddFeed.Title", @"") message:NSLocalizedString(@"RSSFeedListViewController.AddFeed.Message", @"")  delegate:self cancelButtonTitle:NSLocalizedString(@"General.Cancel", @"") otherButtonTitles:NSLocalizedString(@"General.Ok", @""), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_feeds count];
}
-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedItemViewCellIdentifier" forIndexPath:indexPath];
    UIView *bkg = [cell viewWithTag:2];
    bkg.layer.borderColor = [[UIColor blackColor] CGColor];
    bkg.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    bkg.layer.shadowOpacity = 0.5f;
    bkg.layer.shadowOffset = CGSizeZero;
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    RSSFeed *feed = _feeds[indexPath.row];
    label.text = feed.channelTitle != nil ? feed.channelTitle : feed.url;
    return cell;
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(1 == buttonIndex)
    {
        NSURL *url = [NSURL URLWithString:[alertView textFieldAtIndex:0].text];
        if(nil == url || ![[url scheme] isEqualToString:@"http"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RSSFeedListViewController.AddFeed.Title", @"") message:NSLocalizedString(@"RSSFeedListViewController.AddFeed.BadURL", @"")  delegate:self cancelButtonTitle:NSLocalizedString(@"General.Cancel", @"") otherButtonTitles:NSLocalizedString(@"General.Ok", @""), nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
            return;
        }
        //ajout du nouveau feed
        RSSFeed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"RSSFeed" inManagedObjectContext:[self context]];
        feed.url = [url absoluteString];
        //sauvegarde
        NSError *error = nil;
        if(![[self context] save:&error])
        {
            NSLog(@"Error while saving new feed : %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erreur lors de l'ajout du nouveau flux" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        //affichage du détail du flux
        [_feeds addObject:feed];
        [self.collectionView reloadData];
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:[_feeds count] inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showRSSFeed"])
    {
        UICollectionViewCell *cell = (UICollectionViewCell*)sender;
        NSIndexPath *idxPath = [self.collectionView indexPathForCell:cell];
        if(nil != idxPath)
        {
            RSSFeedViewController *destinationController = (RSSFeedViewController*)segue.destinationViewController;
            destinationController.feed = _feeds[idxPath.row];
        }
    }
}
@end
