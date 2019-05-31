//
//  InterstitialKWViewController.m
//  inmobise
//
//  Created by Jason C on 5/31/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import "InterstitialKWViewController.h"
#import "Constants.h"

@interface InterstitialKWViewController ()

@end

@implementation InterstitialKWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeInterstitial];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Function to ensure we create an interstitial and set the delegate.
- (void) initializeInterstitial{
    
    self.interstitialKW = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMPInterstitialID];
    self.interstitialKW.delegate = self;
    
    // Begin a delayed load.
    [self delayedLoadKWInterstitial:kInitialInterstitialLoadDelay];           // Begin loading the interstitial with some delay.
    
}

// IB Action to show the interstitial.
- (IBAction)showKWInterstitial:(id)sender {
    
    if (self.interstitialKW.ready) {
        NSLog(@"%@", [kLogTag stringByAppendingString:@"showInterstitial from DataViewController"]);
        [self.interstitialKW showFromViewController:self];
    } else if (!self.interstitialKW.ready) {
        NSLog(@"%@", [kLogTag stringByAppendingString:@"showInterstitial NOT READY!!"]);
    } else {
        // We shouldn't be here!
    }
}



#pragma mark - <IMAB Delegate Methods>

// When a bid is made with createBid and then submitted, this delegate is called if we do not get a bid
- (void)audienceBidderDidFailBidFor:(id)adObject withError:(NSError *)error {
    
    // If the returned adObject is an interstitial:
    if([adObject isKindOfClass:[MPInterstitialAdController class]]) {
        
        // Load the ad, this won't have the updated bid keywords in it
        [adObject loadAd];
    }
    
    
    
}


// This delegate will be invoked if we are not using bid objects
- (void)audienceBidderDidGenerateBidResponse:(IMBidResponse *)bidResponse {
    
    if ([bidResponse.placement  isEqual: kASInterstitialID]) {
        
        // Set or append the returned InMobi bidResponse keywords on the interstitial
        
        if (bidResponse.keyword != nil) {
            [self.interstitialKW setKeywords:bidResponse.keyword];
        } else if (bidResponse.higherGranularityKeyword != nil) {
            [self.interstitialKW setKeywords:bidResponse.higherGranularityKeyword];
        }
        
        // Update UI with bidResponse results
        [self updateLabelWithKeyword:bidResponse.keyword];
        [self updateLabelWithGranularKeyword:bidResponse.higherGranularityKeyword];
        [self updateLabelWithPrice:bidResponse.price];
        [self updateLabelWithPlacement:bidResponse.placement];
        [self updateLabelWithBuyer:bidResponse.buyer];
        
        // Set the local extras of the interstitial
        self.interstitialKW.localExtras = @{kIMABLocalCacheKey : bidResponse.placement};
        
        // If the bid response placement is a interstitial
        [self.interstitialKW loadAd];
        
    }
    
}



#pragma mark - <IMAB KW Interstitial Methods>

// Function initially called by the controller to begin 'preloading' an interstitial
// This just invokes the loadInterstitial func

- (void) delayedLoadKWInterstitial:(unsigned long long)time  {
    
    // Do a delay before invoking the load interstitial function.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        NSLog(@"%@", [kLogTag stringByAppendingString:@"delayedLoadInterstitial"]);
        
        // Load after some delay.
        [self loadKWInterstitial];
    });
    
}

- (void) delayedSubmitKWInterstitialBid:(unsigned long long)time {
    
    // Do a delay before invoking the load interstitial function.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        NSLog(@"%@", [kLogTag stringByAppendingString:@"delayedSubmitInterstitialBid"]);
        
        //      Submit bid after some delay
        [IMAudienceBidder submitBidForAdType:kIMBiddingAdTypeInterstitial withPlacement:kASInterstitialID andDelegate:self];
        [self indicator_showStateCurrentlyLoading];
    });
    
}


// Function that will submit a bid if bidding logic is enabled.
// If a bid is being submitted, the delegate function is responsible for calling 'loadAd'
// If there is no bid, loadAd will be invoked by this function instead.
- (void) loadKWInterstitial{
    
    [self.intKWReadyIndicator setHidden:false];        // Hide indicator
    [self.intKWReadyIndicator startAnimating];         // Start animation to indicate load cycle has begun.
    
        NSLog(@"%@", [kLogTag stringByAppendingString:@"DataViewController - loadInterstitial - submitBidForAdType - submitBid"]);
        
        [IMAudienceBidder submitBidForAdType:kIMBiddingAdTypeInterstitial withPlacement:kASInterstitialID andDelegate:self];
}

#pragma mark - <MPInterstitialAdControllerDelegate>


- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial{
    
    [self indicator_showStateCurrentlyWaitingForShow];
    NSLog(@"%@", [kLogTag stringByAppendingString:@"interstitialDidLoadAd"]);
    
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    
    // Maybe insert a delay here as well if your expect users to be heavily interacting with the button.
    [self indicator_showStateCurrentlyWaitingForNextLoad];
    [self delayedSubmitKWInterstitialBid:kSuccessLoadInterstitialDelay];
    
    NSLog(@"%@", [kLogTag stringByAppendingString:@"interstitialDidDisappear"]);
}


// When MoPub returns a failed ad, we can go ahead and load another bid after a specified timeout. (~ we'll do 20 seconds)
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%@", [kLogTag stringByAppendingString:@"interstitialDidFailToLoadAd"]);
    [self indicator_showStateCurrentlyWaitingForNextLoad];
    [self delayedSubmitKWInterstitialBid:kFailLoadInterstitialDelay];
    
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%@", [kLogTag stringByAppendingString:@"interstitialDidExpire"]);
}


- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
    NSLog(@"%@", [kLogTag stringByAppendingString:@"interstitialWillAppear"]);
    
}


- (void) indicator_showStateCurrentlyLoading{
    [self.intKWReadyIndicator startAnimating];
    [self.intKWReadyIndicator setHidden:false];
}

- (void) indicator_showStateCurrentlyWaitingForShow{
    [self.intKWReadyIndicator stopAnimating];
    [self.intKWReadyIndicator setHidden:false];
}

- (void) indicator_showStateCurrentlyWaitingForNextLoad{
    [self.intKWReadyIndicator stopAnimating];
    [self.intKWReadyIndicator setHidden:true];
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





@end
