//
//  InterstitialViewController.h
//  inmobise
//
//  Created by Jason C on 5/23/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoPub.h"
#import <InMobiSDK/InMobiSDK.h>


@interface InterstitialViewController : UIViewController <MPAdViewDelegate, MPInterstitialAdControllerDelegate, IMAudienceBidderDelegate>

@property (strong, nonatomic) IMBidObject *interstitialBidOBject;
@property (strong, nonatomic) MPInterstitialAdController *interstitial;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *intReadyIndicator;
@property (weak, nonatomic) IBOutlet UIButton *buttonShowInterstitial;

@end
