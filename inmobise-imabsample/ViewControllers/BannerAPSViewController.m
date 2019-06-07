//
//  BannerAPSViewController.m
//  inmobise
//
//  Created by Jason C on 6/5/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import "BannerAPSViewController.h"
#import "Constants.h"

@interface BannerAPSViewController ()

@end

@implementation BannerAPSViewController

Boolean bannerAPSLoaded = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWrapperObject];
    [self loadBanner];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) initWrapperObject {
    
    // Initialize the wrapper object
    self.bannerWrapper = [[MyAudienceBidder alloc] initWithDelegate:self];
    
    // Set the app ID, APS UUID, InMobi placement, and timeout of the banner wrapper object
    [self.bannerWrapper setA9AppKey:kAPSAppKey];
    [self.bannerWrapper setA9UUID:kAPSBannerUUID];
    [self.bannerWrapper setIMPLCID: kASBannerID ];
    [self.bannerWrapper setTimeout:3.0];
    
}



#pragma mark - <MyAudienceBidder Delegate Methods>


- (void)MyAudienceBidder:(nonnull MyAudienceBidder *)bidder didFailBidFor:(nonnull id)adObject withError:(nonnull NSError *)err {
    
    // If the banner has not yet been loaded, call loadAd on the unchanged MPAdView
    if (!bannerAPSLoaded){
        [self.adView loadAd];
    }
    
    [self label_updateBidStatus:false];
    [self label_clearAttachedKW];

    
}

- (void)MyAudienceBidder:(nonnull MyAudienceBidder *)bidder didReceiveBidFor:(nonnull id)adObject {
    
    // If the banner has not yet been loaded, call loadAd on the updated MPAdView
    if (!bannerAPSLoaded){
        [adObject loadAd];
        
    }

    [self label_updateBidStatus:true];
    [self label_updateAttachedKW:self.adView];

    
}




#pragma mark - <IMAB Banner Methods>


- (void)loadBanner {
    
    // Regardless of which mode, make sure to first load the banner and add it to the view
    self.adView = [[MPAdView alloc] initWithAdUnitId:kMPBannerID size:MOPUB_BANNER_SIZE];
    self.adView.frame = CGRectMake((self.view.bounds.size.width - MOPUB_BANNER_SIZE.width) / 2, self.view.bounds.size.height - (MOPUB_BANNER_SIZE.height), MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height);
    
    // Optional: Add a border and background color so we know the adView has been added
    self.adView.layer.borderColor = [UIColor blackColor].CGColor;
    self.adView.layer.borderWidth = 3;
    self.adView.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    
    [self.view addSubview:self.adView];
    [self.adView stopAutomaticallyRefreshingContents];              // Ensure MoPub banner refresh is disabled. Consult your account manager if you have any questions.
    self.adView.delegate = self;
    
    
    NSLog(@"%@", [kLogTag stringByAppendingString:@"DataViewController loadBanner - createBidForAdType"]);
    
    // Load our Audience Bidder bid with the wrapper to call APS and then the InMobi Audience Bidder in the same call
    [self.bannerWrapper loadMyBidsForBannerWithMopubAdObject:self.adView width:MOPUB_BANNER_SIZE.width height:MOPUB_BANNER_SIZE.height];
    
}



#pragma mark - <MPAdViewDelegate - for Banners!>

- (void)adViewDidLoadAd:(MPAdView *)view {
    
    // Ensure that we do not call loadAd again on the MPAdView
    bannerAPSLoaded = true;
    
    // On a successful load, call submitBid for the next refresh
    [self.bannerWrapper refreshBid];
    
    // Indicate to our controller that we'd like to refresh the ad view
    [self startBannerRefreshTimer];
    
}


- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    
    // Ensure that we do not call loadAd again on the MPAdView
    bannerAPSLoaded = true;
    
    // On a failed load, still call submitBid for the next banner refresh
    [self.bannerWrapper refreshBid];
    
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
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kSelfBannerRefreshTimer
                                     target:self
                                   selector:@selector(triggerManualBannerRefresh)
                                   userInfo:nil
                                    repeats:NO];
    
}


- (void) triggerManualBannerRefresh {
    
    NSLog(@"%@", [kLogTag stringByAppendingString:@"triggerManualBannerRefresh"]);
    
    [self.adView loadAd];
}


- (void)viewDidDisappear:(BOOL)animated {
    
    [self.timer invalidate];
    
}



- (void) label_updateBidStatus:(Boolean)status {
    
    if (status) {
        self.statusLabel.text = @"IMAB Has Bid";
    } else {
        self.statusLabel.text = @"No Bid from IMAB";
    }
    
}


// Suggestion: When debugging / troubleshooting, check the keywords. If InMobi or APS provides an ad, it will be reflected here. 
- (void) label_updateAttachedKW:(MPAdView *)view {
    
    NSLog(@"%@", [kLogTag stringByAppendingString:view.keywords]);
    
    // Update the text label if we have keywords
    if (view.keywords.length > 0 ){
        self.keywordLabel.text = view.keywords;
    }
    
    
}

- (void) label_clearAttachedKW {
    
    NSLog(@"%@", [kLogTag stringByAppendingString:@"No Keywords Found"]);
    
    self.keywordLabel.text = @"No Keywords found";

}


//- (void) label_listCurrentASPLC:(MPAdView *)view {
//
//    NSLog(@"%@", [kLogTag stringByAppendingString:view.localExtras]);
//
//    // Update the text label if we have keywords
//    if (view.keywords.length > 0 ){
//        self.keywordLabel.text = view.keywords;
//    }
//}


@end
