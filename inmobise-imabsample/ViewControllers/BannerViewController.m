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
    [self.adView stopAutomaticallyRefreshingContents];              // Ensure MoPub banner refresh is disabled. Consult your account manager if you have any questions.
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
    
    // Indicate to our controller that we'd like to refresh the ad view
    [self startBannerRefreshTimer];
    
}


- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    
    // Ensure that we do not call loadAd again on the MPAdView
    bannerLoaded = true;
    
    // On a failed load, still call submitBid for the next banner refresh
    [self.bannerBidObject submitBid];
    
    // Indicate to our controller that we'd like to refresh the ad view
    [self startBannerRefreshTimer];

}

#pragma mark - Controlling your own refresh

/*
 **** IMPORTANT NOTE ****
 Mopub IOS SDK does NOT refresh custom keywords even though we update the MPAdView.
 MPBannerAdManager continues to use old keywords until you call loadAd again.
 The impact: Updated prices are not reflected, and this is no longer dynamic bidding.
 
 We have opened a PR here: https://github.com/mopub/mopub-ios-sdk/pull/270
 
 So, this leaves you with 2 choices:
 (if you want this to work and for everyone to earn lots of money)
 - Disable MoPub banner auto-refresh, and use a timer like below to control refresh instead. (This code example)
 - Download MoPub's open source code, tweak as we have in the above PR, and banner auto-refresh with updated keywords will work as intended.
 
 
 DISCLAIMER:
 You may implement a better and more sophisticated timing scheme - however you want.
 Below is just a simple working example.
 */


- (void) startBannerRefreshTimer {
    
    [NSTimer scheduledTimerWithTimeInterval:kSelfBannerRefreshTimer
                                     target:self
                                   selector:@selector(triggerManualBannerRefresh)
                                   userInfo:nil
                                    repeats:NO];
    
}


- (void) triggerManualBannerRefresh {
    
    NSLog(@"%@", [kLogTag stringByAppendingString:@"triggerManualBannerRefresh"]);
    
    [self.adView loadAd];
}



@end
