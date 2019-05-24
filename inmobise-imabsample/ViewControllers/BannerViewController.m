//
//  BannerViewController.m
//  inmobise
//
//  Created by Jason C on 5/23/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import "BannerViewController.h"
#import "Constants.h"

@interface BannerViewController ()

@end

@implementation BannerViewController

Boolean bannerLoaded = false;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadBanner];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <IMAB Delegate Methods>

// When a bid is made with createBid and then submitted, this delegate is called if we do not get a bid
- (void)audienceBidderDidFailBidFor:(id)adObject withError:(NSError *)error {
    
    // If the returned and updated adObject is a banner:
    if([adObject isKindOfClass:[MPAdView class]]) {
        
        // If the banner has not yet been loaded, call loadAd on the updated ad view
        if (!bannerLoaded){
            [self.adView loadAd];
        }
        
    }
    
    
    
}

// When a bid is made with createBid and then submitted, this delegate is called if we get a bid
- (void)audienceBidderDidReceiveBidFor:(id)adObject {
    

    // If the returned and updated adObject is a banner:
    if([adObject isKindOfClass:[MPAdView class]]) {
        
        // If the banner has not yet been loaded, call loadAd on the updated MPAdView
        if (!bannerLoaded){
            self.adView = adObject;
            [self.adView loadAd];
        }
        
    }
    
}


#pragma mark - <IMAB Banner Methods>


- (void)loadBanner {
    
    // Regardless of which mode, make sure to first load the banner and add it to the view
    self.adView = [[MPAdView alloc] initWithAdUnitId:kMPBannerID size:MOPUB_BANNER_SIZE];
    self.adView.frame = CGRectMake((self.view.bounds.size.width - MOPUB_BANNER_SIZE.width) / 2, self.view.bounds.size.height - (MOPUB_BANNER_SIZE.height), MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height);
    [self.view addSubview:self.adView];
    self.adView.delegate = self;
    

    NSLog(@"%@", [kLogTag stringByAppendingString:@"DataViewController loadBanner - createBidForAdType"]);
    self.bannerBidObject = [IMAudienceBidder createBidForAdType:kIMBiddingAdTypeBanner withPlacement:kASBannerID adObj:self.adView andDelegate:self];
    [self.bannerBidObject submitBid];
    
}


#pragma mark - <MPAdViewDelegate - for Banners!>

- (void)adViewDidLoadAd:(MPAdView *)view {
    
    // Ensure that we do not call loadAd again on the MPAdView
    bannerLoaded = true;
    
    // On a successful load, call submitBid for the next refresh
    [self.bannerBidObject submitBid];
    
}


- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    
    // Ensure that we do not call loadAd again on the MPAdView
    bannerLoaded = true;
    
    // On a failed load, still call submitBid for the next banner refresh

    [self.bannerBidObject submitBid];

    
}



@end
