//
//  RSSReader.m
//  Formation
//
//  Created by Brendan GUEGAN on 02/02/12.
//  Copyright (c) 2012 IT&L@bs. All rights reserved.
//

#import "RSSReader.h"
#import "RSSItem.h"
#import "RSSFeed.h"
#import "AppDelegate.h"

static NSString     *   const       kItem                           =   @"item";
static NSString     *   const       kItemTitle                      =   @"title";
static NSString     *   const       kItemDescription                =   @"description";
static NSString     *   const       kItemLink                       =   @"link";
static NSString     *   const       kItemPublicationDate            =   @"pubDate";
static NSString     *   const       kItemThumbnail                  =   @"thumbnail";

static NSString     *   const       RSS_DATE_FORMAT                 =   @"EEE, dd MMM yyyy HH:mm:ss Z";

NSString * const RSSReaderParsingDidFinishNotification              =   @"RSSReaderParsingDidFinishNotification";
NSString * const kRSSReaderParsingDidFinishNotificationFeed         =   @"kRSSReaderParsingDidFinishNotificationFeed";

//Sample date format : Fri, 03 Feb 2012 01:00:00 +0200

@interface RSSReader () <NSXMLParserDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
{
    NSURL                   *_rssURL;
    /*! Reference to the currently parsed item.*/
    RSSItem                  *_currentParsedItem;
    /*! Reference to the current read string.*/
    NSMutableString             *_currentReadString;
    /*! Reference to rss feed used during parsing.*/
    RSSFeed                  *_feed;
    /*! Boolean indicating whether the current element is in item tag.*/
    BOOL                        _parsingItem;
    
    NSMutableData           *_urlSessionData;
}
@property (nonatomic, retain) NSMutableString *_currentReadString;
@end

@implementation RSSReader

@synthesize _currentReadString;
@synthesize feed = _feed;
@synthesize delegate = _delegate;

-(NSManagedObjectContext*) context
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    return appDelegate.managedObjectContext;
}
-(RSSFeed*) feedWithUrl:(NSURL*)url error:(NSError**)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"RSSFeed"];
    request.predicate = [NSPredicate predicateWithFormat:@"url LIKE %@", [url absoluteString]];
    NSArray *result = [[self context] executeFetchRequest:request error:error];
    return [result firstObject];
}
-(RSSFeed*) removeOldFeedItems:(NSError**)error
{
    RSSFeed *feed = [self feedWithUrl:_rssURL error:error];
    if(nil != *error)
    {
        return nil;
    }
    [feed.items enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        RSSItem *item = (RSSItem*)obj;
        [[self context] deleteObject:item];
    }];
    feed.items = nil;
    if(![[self context] save:error])
    {
        return nil;
    }
    return feed;
}

-(instancetype) initWithURL:(NSURL*)url
{
    self = [super init];
    if(self)
    {
        _rssURL = url;
    }
    return self;
}

-(void) startParsing
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    [[session dataTaskWithURL:_rssURL] resume];
}

-(void) startParsingWithCompletion:(void (^)(RSSFeed *, NSError *))completionBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    [session dataTaskWithURL:_rssURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(nil != error)
        {
            completionBlock(nil, error);
            return;
        }
        //s'il n'y en a pas, on peut créer l'instance de NSXMLParser
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_urlSessionData];
        //attention à ne pas oublier de se mettre en délégué de l'instance de NSXMLParser
        parser.delegate = self;
        if([parser parse])
        {
            //sauvegarde des données
            NSError *saveError = nil;
            if(![[self context] save:&saveError])
            {
                _feed = nil;
                [[self context] rollback];
                completionBlock(nil, saveError);
                return;
            }
            completionBlock(_feed, nil);
        }
        else
        {
            completionBlock(nil, [parser parserError]);
        }
    }];
}

#pragma mark - NSURLSessionDelegate protocol implementation
//méthode appelée quand la session n'est plus valide
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    [_delegate rssReader:self didFailWithError:error];
    [[NSNotificationCenter defaultCenter] postNotificationName:RSSReaderParsingDidFinishNotification object:self userInfo:@{NSLocalizedFailureReasonErrorKey : [error localizedFailureReason], NSLocalizedDescriptionKey : [error localizedDescription]}];
}
#pragma mark - NSURLSessionTaskDelegate protocol implementation
//méthode appelée à la fin du téléchargement
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //vérifier l'erreur
    if(nil != error)
    {
        [_delegate rssReader:self didFailWithError:error];
        return;
    }
    //s'il n'y en a pas, on peut créer l'instance de NSXMLParser
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_urlSessionData];
    //attention à ne pas oublier de se mettre en délégué de l'instance de NSXMLParser
    parser.delegate = self;
    if([parser parse])
    {
        //sauvegarde des données
        NSError *saveError = nil;
        if(![[self context] save:&saveError])
        {
            _feed = nil;
            [[self context] rollback];
            [_delegate rssReader:self didFailWithError:saveError];
            [[NSNotificationCenter defaultCenter] postNotificationName:RSSReaderParsingDidFinishNotification object:self userInfo:@{NSLocalizedFailureReasonErrorKey : [saveError localizedFailureReason], NSLocalizedDescriptionKey : [saveError localizedDescription]}];
            return;
        }
        [_delegate rssReader:self didFinishWithFeed:_feed];
        [[NSNotificationCenter defaultCenter] postNotificationName:RSSReaderParsingDidFinishNotification object:self userInfo:@{kRSSReaderParsingDidFinishNotificationFeed : _feed}];
    }
    else
    {
        [_delegate rssReader:self didFailWithError:[parser parserError]];
        [[NSNotificationCenter defaultCenter] postNotificationName:RSSReaderParsingDidFinishNotification object:self userInfo:@{NSLocalizedFailureReasonErrorKey : [[parser parserError] localizedFailureReason], NSLocalizedDescriptionKey : [[parser parserError] localizedDescription]}];
    }
}
#pragma mark - NSURLSessionDataDelegate protocol implementation
//méthode appelée lors de la réception de données
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //ajout des données dans un buffer
    if(nil == _urlSessionData)
    {
        _urlSessionData = [NSMutableData new];
    }
    [_urlSessionData appendData:data];
}
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    if([response respondsToSelector:@selector(statusCode)])
    {
        NSInteger code = [((NSHTTPURLResponse*)response) statusCode];
        if(200 != code)
        {
            //le serveur n'a pas retourné le code 200, il y a un problème.
            completionHandler(NSURLSessionResponseCancel);
        }
        else
        {
            completionHandler(NSURLSessionResponseAllow);
        }
    }
}

#pragma mark - NSXMLParserDelegate protocol implementation

//méthode qui est appelée à chaque fois que le parser trouve un élément
//le nom de l'élément est fourni ainsi que ses attributs
// on teste alors le nom de d'élément pour apporter le traitement approprié
-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:kItem])
    {
        if(nil != _currentParsedItem)
        {
            _currentParsedItem = nil;
        }
        _currentParsedItem = [NSEntityDescription insertNewObjectForEntityForName:@"RSSItem" inManagedObjectContext:[self context]];
        _parsingItem = YES;
    }
    else if([elementName isEqualToString:kItemTitle] || [elementName isEqualToString:kItemDescription] || [elementName isEqualToString:kItemLink] || [elementName isEqualToString:kItemPublicationDate])
    {
        self._currentReadString = [NSMutableString string];
    }
}
//méthode qui est appelée à chaque fois que le parser termine un élément
// on teste alors le nom de d'élément pour apporter le traitement approprié
-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:kItem])
    {
        if(nil != _currentParsedItem)
        {
            [_feed addItemsObject:_currentParsedItem];
            _currentParsedItem = nil;
        }
        _parsingItem = NO;
    }
    else if([elementName isEqualToString:kItemTitle])
    {
        if(!_parsingItem)
        {
            _feed.channelTitle = self._currentReadString;
            self._currentReadString = nil;
        }
        else if(nil != _currentParsedItem)
        {
            _currentParsedItem.title = self._currentReadString;
            self._currentReadString = nil;
        }
    }
    else if([elementName isEqualToString:kItemDescription])
    {
        
        if(nil != _currentParsedItem)
        {
            _currentParsedItem.content = self._currentReadString;
            self._currentReadString = nil;
        }
    }
    else if([elementName isEqualToString:kItemLink])
    {
        
        if(nil != _currentParsedItem)
        {
            _currentParsedItem.link = self._currentReadString;
            self._currentReadString = nil;
        }
    }
    else if([elementName isEqualToString:kItemPublicationDate])
    {
        
        if(nil != _currentParsedItem)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:RSS_DATE_FORMAT];
            NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
            [formatter setLocale:enLocale];
            NSDate *resDate = [formatter dateFromString:self._currentReadString];
            if(nil == resDate)
            {
                NSLog(@"unable to parse date from string : '%@'", self._currentReadString);
            }
            _currentParsedItem.publicationDate = resDate;
            self._currentReadString = nil;
        }
    }
    
}
//méthode appelée à chaque fois que le parser détecte des caractères entre 2 balises
//typiquement, dnas le cas d'une balise <balise>mon texte</balise>
//le texte est alors "mon texte"
// ATTENTION cependant, cette méthode peut être appelée plusieurs fois pour du texte entre 2 balises,
// par exemple, il peut y avoir un appel avec le texte "mon ", et un second avec "texte"
-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //ajout de la chaîne string dans un buffer
    if(nil != self._currentReadString)
    {
        [self._currentReadString appendString:string];
    }
}

//méthode appelée à chaque fois que le parser détecte des balises <![CDATA[
// ATTENTION cependant, comme la méthode précédente, cette méthode peut être appelée plusieurs fois pour de la donnée CDATA,
-(void) parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    //ajout de la donnée dans un buffer
    //ajout de la chaîne string dans un buffer
    if(nil != self._currentReadString)
    {
        [self._currentReadString appendString:[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding]];
    }
}
// méthode appelée quand une erreur de parsing a été rencontrée,
// par exemple, lorsque une balise de fin ne correspond pas
-(void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"error(%d) while parsing RSS feed : %@", [parseError code], [parseError localizedDescription]);
}
-(void) parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    NSLog(@"error(%d) while validating RSS feed : %@", [validationError code], [validationError localizedDescription]);
}
//méthode appelée au début du parsing
-(void) parserDidStartDocument:(NSXMLParser *)parser
{
    //initilisation du feed
    NSLog(@"start parsing RSS feed");
    NSError *error = nil;
    RSSFeed *feed = [self removeOldFeedItems:&error];
    if(nil != error)
    {
        NSLog(@"error while retrieving feed : %@", error);
    }
    else if(nil != feed)
    {
        _feed = feed;
    }
    else
    {
        _feed = [NSEntityDescription insertNewObjectForEntityForName:@"RSSFeed" inManagedObjectContext:[self context]];
        _feed.url = [_rssURL absoluteString];
    }
    _parsingItem = NO;
}
//méthode appelée à la fin du parsing
-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"end parsing RSS feed");
}
@end
