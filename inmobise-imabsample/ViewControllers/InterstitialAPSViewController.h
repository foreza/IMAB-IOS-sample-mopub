//
//  InterstitialAPSViewController.h
//  inmobise
//
//  Created by Jason C on 6/5/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoPub.h"
#import <InMobiSDK/InMobiSDK.h>
#import "MyAudienceBidder.h"

@interface InterstitialAPSViewController : UIViewController <MPInterstitialAdControllerDelegate, MyAudienceBidderDelegate>

@property (strong, nonatomic) MPInterstitialAdController *interstitial;       // FOR MoPub Interstitial
@property (strong, nonatomic) MyAudienceBidder *interstitialWrapper;          // Audience bidder with APS Wrapper strong reference
@property (weak, nonatomic) IBOutlet UILabel *keywordLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *intAPSReadyIndicator;
@property (weak, nonatomic) IBOutlet UIButton *showAPSInterstitialButton;

@end
