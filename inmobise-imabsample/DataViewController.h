//  DataViewController.h

#import <UIKit/UIKit.h>
#import "MoPub.h"
#import <InMobiSDK/InMobiSDK.h>


@interface DataViewController : UIViewController <MPAdViewDelegate, MPInterstitialAdControllerDelegate, IMAudienceBidderDelegate>


@property (strong, nonatomic) IMBidObject *bannerBidObject;                         // Audience Bidder banner bid object reference
@property (strong, nonatomic) IMBidObject *interstitialBidOBject;                   // Audience Bidder interstitial bid object reference
@property (strong, nonatomic) MPAdView *adView;                                     // For MoPub Banner - currently unused
@property (strong, nonatomic) MPInterstitialAdController *interstitial;             // For MoPub Interstitial - currently unused



// UI IBOutlet references
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *intReadyIndicator;
@property (weak, nonatomic) IBOutlet UITextField *MoPubSDKVersion;
@property (weak, nonatomic) IBOutlet UITextField *AerServSDKVersion;



@end

