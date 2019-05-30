//
//  BannerKWViewController.h
//  inmobise
//
//  Created by Jason C on 5/30/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoPub.h"
#import <InMobiSDK/InMobiSDK.h>

@interface BannerKWViewController : UIViewController <MPAdViewDelegate, IMAudienceBidderDelegate>

@property (strong, nonatomic) MPAdView *adView;                                     // For MoPub Banner

@property (weak, nonatomic) IBOutlet UILabel *labelKeyword;
@property (weak, nonatomic) IBOutlet UILabel *labelGranularKeyword;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelPlacement;
@property (weak, nonatomic) IBOutlet UILabel *labelBuyer;

@end
