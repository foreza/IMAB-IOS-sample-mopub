//
//  InterstitialViewController.m
//  inmobise
//
//  Created by Jason C on 5/23/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import "InterstitialViewController.h"
#import "Constants.h"

@interface InterstitialViewController ()

@end

@implementation InterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeInterstitial];
    [self indicator_showInitialState];      

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Function to ensure we create an interstitial and set the delegate.
- (void) initializeInterstitial{
    
    self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMPInterstitialID];
    self.interstitial.delegate = self;
    
    // Begin a delayed load.
    [self delayedLoadInterstitial:kInitialInterstitialLoadDelay];           // Begin loading the interstitial with some delay.
    
}

// IB Action to show the interstitial.
- (IBAction)showInterstitial:(id)sender {
    
    if (self.interstitial.ready) {
        NSLog(@"%@", [kLogTag stringByAppendingString:@"showInterstitial from DataViewController"]);
        [self.interstitial showFromViewController:self];
    } else if (!self.interstitial.ready) {
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

// When a bid is made with createBid and then submitted, this delegate is called if we get a bid
- (void)audienceBidderDidReceiveBidFor:(id)adObject {
    
    // If the returned adObject is an interstitial:
    if([adObject isKindOfClass:[MPInterstitialAdController class]]) {
        
        // Load the ad, which will have the updated bid keywords included
        [adObject loadAd];
    }
    
}

// This delegate will be invoked if we are not using bid objects
- (void)audienceBidderDidGenerateBidResponse:(IMBidResponse *)bidResponse {
    
    if ([bidResponse.placement  isEqual: kASInterstitialID]) {
        
        // Set or append the returned InMobi bidResponse keywords on the interstitial
        
        if (bidResponse.keyword != nil) {
            [self.interstitial setKeywords:bidResponse.keyword];
        } else if (bidResponse.higherGranularityKeyword != nil) {
            [self.interstitial setKeywords:bidResponse.higherGranularityKeyword];
        }
        
        
        // Set the local extras of the interstitial
        self.interstitial.localExtras = @{kIMABLocalCacheKey : bidResponse.placement};
        
        // If the bid response placement is a interstitial
        [self.interstitial loadAd];
        
    }
    
}



#pragma mark - <IMAB Interstitial Methods>

// Function initially called by the controller to begin 'preloading' an interstitial
// This just invokes the loadInterstitial func

- (void) delayedLoadInterstitial:(unsigned long long)time  {
    
    // Do a delay before invoking the load interstitial function.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        NSLog(@"%@", [kLogTag stringByAppendingString:@"delayedLoadInterstitial"]);
        
        // Load after some delay.
        [self loadInterstitial];
    });
    
}

- (void) delayedSubmitInterstitialBid:(unsigned long long)time {
    
    // Do a delay before invoking the load interstitial function.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        NSLog(@"%@", [kLogTag stringByAppendingString:@"delayedSubmitInterstitialBid"]);
        
        //      Submit bid after some delay
        [self.interstitialBidOBject submitBid];
        [self indicator_showStateCurrentlyLoading];
    });
    
}


// Function that will submit a bid if bidding logic is enabled.
// If a bid is being submitted, the delegate function is responsible for calling 'loadAd'
// If there is no bid, loadAd will be invoked by this function instead.
- (void) loadInterstitial{
    
    [self.intReadyIndicator setHidden:false];        // Hide indicator
    [self.intReadyIndicator startAnimating];         // Start animation to indicate load cycle has begun.
    
    
    if (kSupportAB){
        NSLog(@"%@", [kLogTag stringByAppendingString:@"DataViewController - loadInterstitial - createBidForAdType - submitBid"]);
        self.interstitialBidOBject = [IMAudienceBidder createBidForAdType:kIMBiddingAdTypeInterstitial withPlacement:kASInterstitialID adObj:self.interstitial andDelegate:self];
        [self.interstitialBidOBject submitBid];
    } else {
        [self.interstitial loadAd];
        NSLog(@"%@", [kLogTag stringByAppendingString:@"DataViewController - loadInterstitial"]);
    }
    
}

#pragma mark - <MPInterstitialAdControllerDelegate>


- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial{
    
    [self indicator_showStateCurrentlyWaitingForShow];
    NSLog(@"%@", [kLogTag stringByAppendingString:@"interstitialDidLoadAd"]);
    
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    
    // Maybe insert a delay here as well if your expect users to be heavily interacting with the button.
    [self indicator_showStateCurrentlyWaitingForNextLoad];
    [self delayedSubmitInterstitialBid:kSuccessLoadInterstitialDelay];
    
    NSLog(@"%@", [kLogTag stringByAppendingString:@"interstitialDidDisappear"]);
}


// When MoPub returns a failed ad, we can go ahead and load another bid after a specified timeout. (~ we'll do 20 seconds)
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%@", [kLogTag stringByAppendingString:@"interstitialDidFailToLoadAd"]);
    [self indicator_showStateCurrentlyWaitingForNextLoad];
    [self delayedSubmitInterstitialBid:kFailLoadInterstitialDelay];
    
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%@", [kLogTag stringByAppendingString:@"interstitialDidExpire"]);
}


- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
    NSLog(@"%@", [kLogTag stringByAppendingString:@"interstitialWillAppear"]);
    
}

- (void) indicator_showInitialState{
    [self.intReadyIndicator setHidden:true];
    [self.intReadyIndicator setColor:UIColor.darkGrayColor];
}


- (void) indicator_showStateCurrentlyLoading{
    [self.intReadyIndicator setHidden:false];
    [self.intReadyIndicator startAnimating];
    [self.intReadyIndicator setColor:UIColor.darkGrayColor];
}

- (void) indicator_showStateCurrentlyWaitingForShow{
    [self.intReadyIndicator setHidden:false];
    [self.intReadyIndicator stopAnimating];
    [self.intReadyIndicator setColor:UIColor.greenColor];
}

- (void) indicator_showStateCurrentlyWaitingForNextLoad{
    [self.intReadyIndicator setHidden:false];
    [self.intReadyIndicator stopAnimating];
    [self.intReadyIndicator setColor:UIColor.redColor];
}



@end
