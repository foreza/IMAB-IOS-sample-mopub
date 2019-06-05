//
//  InterstitialKWViewController.h
//  inmobise
//
//  Created by Jason C on 5/31/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoPub.h"
#import <InMobiSDK/InMobiSDK.h>

@interface InterstitialKWViewController : UIViewController <MPInterstitialAdControllerDelegate, IMAudienceBidderDelegate>

@property (strong, nonatomic) MPInterstitialAdController *interstitialKW;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *intKWReadyIndicator;
@property (weak, nonatomic) IBOutlet UIButton *buttonShowKWInterstitial;

@property (weak, nonatomic) IBOutlet UILabel *labelKeyword;
@property (weak, nonatomic) IBOutlet UILabel *labelGranularKeyword;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelPlacement;
@property (weak, nonatomic) IBOutlet UILabel *labelBuyer;


@end
