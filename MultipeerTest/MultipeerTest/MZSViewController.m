//
//  MZSViewController.m
//  MultipeerTest
//
//  Created by Matt Sanford on 2013-09-24.
//  Copyright (c) 2013 MZSanford, LLC. All rights reserved.
//

#import "MZSViewController.h"

const NSString *kDownloadUrl = @"http://mzs.local:4000/62mb.zip";
const NSString *kServiceType = @"mzs-test";

@interface MZSViewController ()

// Download stuff
@property (nonatomic, strong) NSURLConnection *downloadConnection;
@property (nonatomic) NSUInteger expectedDownloadSize;
@property (nonatomic) NSUInteger currentDownloadSize;
@property (nonatomic) NSDate *firstChunkTime;

// Browser stuff
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

// Advertiser stuff
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic) BOOL downloading;
@property (nonatomic) BOOL browsing;
@property (nonatomic) BOOL advertising;

@end

@implementation MZSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.downloading = self.browsing = self.advertising = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - button actions

- (void)tappedDownload:(id)sender
{
    if (self.downloading) {
        [self.downloadConnection cancel];
        [self.startDownloadButton setTitle:@"Start Downloading" forState:UIControlStateNormal];
        self.downloading = NO;
    } else {
        NSURL *url = [NSURL URLWithString:(NSString *)kDownloadUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        self.downloadConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [self.startDownloadButton setTitle:@"Connecting ..." forState:UIControlStateNormal];
        self.downloading = YES;
    }
}

- (void)tappedBrowser:(id)sender
{
    if (self.browsing) {
        [self.browser stopBrowsingForPeers];
        self.browser = nil;
        [self.startBrowserButton setTitle:@"Start Browsing" forState:UIControlStateNormal];
        self.browsing = NO;
    } else {
        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:@"test browser"];
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID serviceType:(NSString *)kServiceType];
        self.browser.delegate = self;
        [self.browser startBrowsingForPeers];
        [self.startBrowserButton setTitle:@"Stop Browsing" forState:UIControlStateNormal];
        self.browsing = YES;
    }
}

- (void)tappedAdvertiser:(id)sender
{
    if (self.advertising) {
        [self.advertiser stopAdvertisingPeer];
        self.advertiser = nil;
        [self.startAdvertiserButton setTitle:@"Start Advertising" forState:UIControlStateNormal];
        self.advertising = NO;
    } else {
        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:@"test advertiser"];
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID
                                                            discoveryInfo:@{
                                                                            @"key": @"value"
                                                                            }
                                                              serviceType:(NSString *)kServiceType];
        [self.startAdvertiserButton setTitle:@"Stop Advertising" forState:UIControlStateNormal];
        self.advertising = YES;
    }
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection: (NSURLConnection*) connection didReceiveResponse: (NSHTTPURLResponse*) response
{
    if ([response statusCode] == 200) {
        self.expectedDownloadSize = [response expectedContentLength];
        self.currentDownloadSize = 0;
        self.firstChunkTime = nil;
        [self.startDownloadButton setTitle:@"Stop Downloading" forState:UIControlStateNormal];
        self.downloading = YES;
    } else {
        // Request error. What now?
        @throw @"what now?";
    }
}

- (void) connection: (NSURLConnection*) connection didReceiveData:(NSData*) data
{
    NSDate *chunkTime = [NSDate date];
    NSUInteger chunkSize = [data length];

    self.currentDownloadSize += chunkSize;

    if (self.firstChunkTime) {
        float duration = [chunkTime timeIntervalSinceDate:self.firstChunkTime];
        float rate = (self.currentDownloadSize / duration) / (1024*1024);
        self.rateLabel.text = [NSString stringWithFormat:@"%0.4f", rate];
    } else {
        self.firstChunkTime = chunkTime;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.downloading = NO;
    [self.startDownloadButton setTitle:@"Start Downloading" forState:UIControlStateNormal];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate methods

- (void)           advertiser:(MCNearbyServiceAdvertiser *)advertiser
 didReceiveInvitationFromPeer:(MCPeerID *)peerID
                  withContext:(NSData *)context
            invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler;
{
    NSLog(@"Advert callback I don't care about");
}

#pragma mark - MCNearbyServiceBrowserDelegate methods

// Found a nearby advertising peer
- (void)browser:(MCNearbyServiceBrowser *)browser
      foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"Found peer");
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser
       lostPeer:(MCPeerID *)peerID
{
    NSLog(@"Lost peer");
}

- (void)             browser:(MCNearbyServiceBrowser *)browser
 didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"Error starting service browser: %@", error);
}


@end
