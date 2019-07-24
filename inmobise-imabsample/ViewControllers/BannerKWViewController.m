//
//  BannerKWViewController.m
//  inmobise
//
//  Created by Jason C on 5/30/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import "BannerKWViewController.h"
#import "Constants.h"

@interface BannerKWViewController ()

@end

@implementation BannerKWViewController

Boolean bannerKWLoaded = false;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self loadKWBanner];
    [self loadKWMREC];

}


#pragma mark - <IMAB Delegate Methods>

// When a bid is made with createBid and then submitted, this delegate is called if we do not get a bid
- (void)audienceBidderDidFailBidFor:(id)adObject withError:(NSError *)error {
    
    // If the returned and updated adObject is a banner:
    if([adObject isKindOfClass:[MPAdView class]]) {
        
        // If the banner has not yet been loaded, call loadAd on the updated ad view
        if (!bannerKWLoaded){
            [self.adView loadAd];
        }
        
    }
    
    
    
}


// This delegate should be invoked if we are not using bid objects and used submitBidForAdType
- (void)audienceBidderDidGenerateBidResponse:(IMBidResponse *)bidResponse {
        
    // Set or append the returned InMobi bidResponse keywords on the adView
    [self.adView setKeywords:bidResponse.keyword];
    
    // Update UI with bidResponse results
    [self updateLabelWithKeyword:bidResponse.keyword];
    [self updateLabelWithGranularKeyword:bidResponse.higherGranularityKeyword];
    [self updateLabelWithPrice:bidResponse.price];
    [self updateLabelWithPlacement:bidResponse.placement];
    [self updateLabelWithBuyer:bidResponse.buyer];
        
    // Set the local extras of the adview
    self.adView.localExtras = @{kIMABLocalCacheKey : bidResponse.placement};
        
        // If the banner has not yet been loaded, call loadAd on the updated MPAdView
        if (!bannerKWLoaded){
            [self.adView loadAd];
        }
    
}



#pragma mark - <IMAB Banner Methods>

- (void) submitBannerKWBid {
    
    NSLog(@"%@", [kLogTag stringByAppendingString:@"IMAudienceBidder - submitBannerKWBid"]);

    // Call submitBidForAdType if you plan to add keywords to the object yourself. Note that this doesn't give you a bid object.
//    [IMAudienceBidder submitBidForAdType:kIMBiddingAdTypeBanner withPlacement:kASBannerID andDelegate:self];
    [IMAudienceBidder submitBidForAdType:kIMBiddingAdTypeBanner withPlacement:kASBannerID adSize:MOPUB_BANNER_SIZE andDelegate:self];

}


- (void) submitMRECKWBid {
    
    NSLog(@"%@", [kLogTag stringByAppendingString:@"IMAudienceBidder - submitMRECKWBid"]);
    
    // Call submitBidForAdType if you plan to add keywords to the object yourself. Note that this doesn't give you a bid object.
    // [IMAudienceBidder submitBidForAdType:kIMBiddingAdTypeBanner withPlacement:kASMRECID andDelegate:self];
    [IMAudienceBidder submitBidForAdType:kIMBiddingAdTypeBanner withPlacement:kASMRECID adSize:MOPUB_MEDIUM_RECT_SIZE andDelegate:self];
}


- (void)loadKWBanner {
    
    // Regardless of which mode, make sure to first load the banner and add it to the view
    self.adView = [[MPAdView alloc] initWithAdUnitId:kMPBannerID size:MOPUB_BANNER_SIZE];
    self.adView.frame = CGRectMake((self.view.bounds.size.width - MOPUB_BANNER_SIZE.width) / 2, self.view.bounds.size.height - (MOPUB_BANNER_SIZE.height), MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height);
    
    // Optional: Add a border and background color so we know the adView has been added
    self.adView.layer.borderColor = [UIColor blackColor].CGColor;
    self.adView.layer.borderWidth = 3;
    self.adView.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
    
    [self.view addSubview:self.adView];
    [self.adView stopAutomaticallyRefreshingContents];              // Ensure MoPub banner refresh is disabled. Consult your account manager if you have any questions.
    self.adView.delegate = self;
    
    [self submitBannerKWBid];                                       // Unlike the non keyword approach, we don't use banner bid objects. You'll have to submit a new bid each time.
    
}

- (void)loadKWMREC {
    
    // Regardless of which mode, make sure to first load the banner and add it to the view
    self.adView = [[MPAdView alloc] initWithAdUnitId:kMPMRECID size:MOPUB_MEDIUM_RECT_SIZE];
    self.adView.frame = CGRectMake((self.view.bounds.size.width - MOPUB_MEDIUM_RECT_SIZE.width) / 2, self.view.bounds.size.height - (MOPUB_MEDIUM_RECT_SIZE.height), MOPUB_MEDIUM_RECT_SIZE.width, MOPUB_MEDIUM_RECT_SIZE.height);
    
    // Optional: Add a border and background color so we know the adView has been added
    self.adView.layer.borderColor = [UIColor blackColor].CGColor;
    self.adView.layer.borderWidth = 3;
    self.adView.layer.backgroundColor = [UIColor redColor].CGColor;
    
    [self.view addSubview:self.adView];
    [self.adView stopAutomaticallyRefreshingContents];              // Ensure MoPub banner refresh is disabled. Consult your account manager if you have any questions.
    self.adView.delegate = self;
    
    [self submitMRECKWBid];                                       // Unlike the non keyword approach, we don't use banner bid objects. You'll have to submit a new bid each time.
    
}



#pragma mark - <MPAdViewDelegate - for Banners!>

- (void)adViewDidLoadAd:(MPAdView *)view {
    
    // Ensure that we do not call loadAd again on the MPAdView
    bannerKWLoaded = true;
    
    // On a successful load, call submitBidForAdType for the next refresh
    // [self submitBannerKWBid];
    [self submitMRECKWBid];

    // Indicate to our controller that we'd like to refresh the ad view
    [self startBannerRefreshTimer];
    
}


- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    
    // Ensure that we do not call loadAd again on the MPAdView
    bannerKWLoaded = true;
    
    // On a successful load, call submitBidForAdType for the next refresh
    // [self submitBannerKWBid];
    [self submitMRECKWBid];
    
    // Indicate to our controller that we'd like to refresh the ad view
    [self startBannerRefreshTimer];
    
}

#pragma mark - UILabel updating

- (void) updateLabelWithKeyword: (NSString *) val {
    [self.labelKeyword setText:val];
}

- (void) updateLabelWithGranularKeyword: (NSString *) val {
    [self.labelGranularKeyword setText:val];
}

- (void) updateLabelWithPrice: (NSNumber*) val {
    [self.labelPrice setText:[val stringValue]];
}

- (void) updateLabelWithPlacement: (NSString *) val {
    [self.labelPlacement setText:val];
}

- (void) updateLabelWithBuyer: (NSString *) val {
    [self.labelBuyer setText:val];
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
                                   selector:@selector(triggerManualBannerKWRefresh)
                                   userInfo:nil
                                    repeats:NO];
    
}


- (void) triggerManualBannerKWRefresh {
    
    NSLog(@"%@", [kLogTag stringByAppendingString:@"triggerManualBannerKWRefresh"]);
    
    [self.adView loadAd];
}


@end
