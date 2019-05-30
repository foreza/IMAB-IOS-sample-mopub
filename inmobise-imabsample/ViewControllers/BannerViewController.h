//
//  BannerViewController.h
//  inmobise
//
//  Created by Jason C on 5/23/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoPub.h"
#import <InMobiSDK/InMobiSDK.h>

@interface BannerViewController : UIViewController <MPAdViewDelegate, IMAudienceBidderDelegate>

@property (strong, nonatomic) IMBidObject *bannerBidObject;                         // Audience Bidder banner bid object reference
@property (strong, nonatomic) MPAdView *adView;                                     // For MoPub Banner

@end
