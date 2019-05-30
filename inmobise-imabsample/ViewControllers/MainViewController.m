//  DataViewController.m

#import "MainViewController.h"
#import "Constants.h"


@implementation MainViewController

#pragma mark - <View / IB Actions / Init methods>

- (void)viewDidLoad {

    NSLog(@"%@", [kLogTag stringByAppendingString:@"DataViewController - viewDidLoad"]);
    
    [self setupAdditionalViewElements];
    [self initializeSDKs];
    [super viewDidLoad];
    
}

// Extra fluff: Gets the SDK versions and sets labels.
- (void)setupAdditionalViewElements{
    
    // Set title and text information for SDK versions
    self.title = kAppName;
    
    _IMUnifiedSDKVersion.text = [NSString stringWithFormat:@"%s%@", "InMobi SDK Version: ", [AerServSDK sdkVersion]];
    _MoPubSDKVersion.text = [NSString stringWithFormat:@"%s%@", "MoPub SDK Version: ", MP_SDK_VERSION];
    
}

// Handle any initialization here.
-(void)initializeSDKs {

    // Init the IM Audience Bidder SDK
    [IMAudienceBidder initializeWithAppID:kIMABAppID andUserConsent:@{ IM_GDPR_CONSENT_AVAILABLE : @YES }];
    
}




#pragma mark - <Misc Methods>

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}






@end
