//
//  BannerAPSViewController.h
//  inmobise
//
//  Created by Jason C on 6/5/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoPub.h"
#import <InMobiSDK/InMobiSDK.h>
#import "MyAudienceBidder.h"

@interface BannerAPSViewController : UIViewController <MPAdViewDelegate, MyAudienceBidderDelegate>

@property (strong, nonatomic) MPAdView *adView;                     // For MoPub Banner
@property (strong, nonatomic) MyAudienceBidder *bannerWrapper;      // Audience bidder with APS Wrapper strong reference
@property (strong, nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UILabel *keywordLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
