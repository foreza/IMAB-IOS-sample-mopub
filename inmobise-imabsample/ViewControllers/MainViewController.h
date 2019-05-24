//  DataViewController.h

#import <UIKit/UIKit.h>
#import "MoPub.h"
#import <InMobiSDK/InMobiSDK.h>


@interface MainViewController : UIViewController <MPAdViewDelegate, MPInterstitialAdControllerDelegate, IMAudienceBidderDelegate>


// UI IBOutlet references
@property (weak, nonatomic) IBOutlet UITextField *MoPubSDKVersion;
@property (weak, nonatomic) IBOutlet UITextField *AerServSDKVersion;



@end

