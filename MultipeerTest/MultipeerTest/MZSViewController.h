//
//  MZSViewController.h
//  MultipeerTest
//
//  Created by Matt Sanford on 2013-09-24.
//  Copyright (c) 2013 MZSanford, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MZSViewController : UIViewController <NSURLConnectionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (nonatomic, strong) IBOutlet UIButton *startDownloadButton;
@property (nonatomic, strong) IBOutlet UIButton *startBrowserButton;
@property (nonatomic, strong) IBOutlet UIButton *startAdvertiserButton;
@property (nonatomic, strong) IBOutlet UILabel  *rateLabel;

- (IBAction)tappedDownload:(id)sender;
- (IBAction)tappedBrowser:(id)sender;
- (IBAction)tappedAdvertiser:(id)sender;

@end
