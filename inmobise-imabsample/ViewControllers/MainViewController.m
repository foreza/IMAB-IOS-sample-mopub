//  DataViewController.m

#import "MainViewController.h"
#import "Constants.h"


@implementation MainViewController

#pragma mark - <View / IB Actions / Init methods>

- (void)viewDidLoad {

    NSLog(@"%@", [kLogTag stringByAppendingString:@"DataViewController - viewDidLoad"]);
    
    [self setupAdditionalViewElements];
    [self intializeSDKs];
    [super viewDidLoad];
    
}

// Extra fluff: Gets the SDK versions and sets labels.
- (void)setupAdditionalViewElements{
    
    // Set title and text information for SDK versions
    self.title = kAppName;
    
    _AerServSDKVersion.text = [AerServSDK sdkVersion];
    _MoPubSDKVersion.text = MP_SDK_VERSION;
    
}

// Handle any initialization here.
-(void)intializeSDKs {

    // Init the IM Audience Bidder SDK
    [IMAudienceBidder initializeWithAppID:kIMABAppID andUserConsent:@{ IM_GDPR_CONSENT_AVAILABLE : @YES }];
    
}




// IB Action to load the banner into the view. No preload logic here.
- (IBAction)loadBanner:(id)sender {
    
    [self loadBanner];
    
}







#pragma mark - <IMAB Banner Methods>


- (void)loadBanner {
    
    // TODO
    
}




#pragma mark - <MPAdViewDelegate - for Banners!>

- (void)adViewDidLoadAd:(MPAdView *)view {
    
    // TODO
    
}


- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    
    // TODO
    
}






#pragma mark - <Misc Methods>

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}






@end
