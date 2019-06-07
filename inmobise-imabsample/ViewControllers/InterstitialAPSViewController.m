//
//  InterstitialAPSViewController.m
//  inmobise
//
//  Created by Jason C on 6/5/19.
//  Copyright © 2019 Jason C. All rights reserved.
//

#import "InterstitialAPSViewController.h"
#import "Constants.h"

@interface InterstitialAPSViewController ()

@end

@implementation InterstitialAPSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initWrapperObject];
    [self initializeInterstitial];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initWrapperObject {
    
    // Initialize the wrapper object
    self.interstitialWrapper = [[MyAudienceBidder alloc] initWithDelegate:self];
    
    // Set the app ID, APS UUID, InMobi placement, and timeout of the interstitial wrapper object
//    [self.interstitialWrapper setA9AppKey:kAPSVideoAppKey];
//    [self.interstitialWrapper setA9UUID: kAPSInterstitialVideoUUID];
//    [self.interstitialWrapper setIMPLCID: kASInterstitialID];
//    [self.interstitialWrapper  setTimeout:3.0];
    
    [self.interstitialWrapper setA9AppKey:kQAA9AppId];
    [self.interstitialWrapper setA9UUID: kQAA9InterstitialSlotId];
    [self.interstitialWrapper setIMPLCID: kQAASInterstitialID];
    [self.interstitialWrapper  setTimeout:3.0];
    
    
}


// Function to ensure we create an interstitial and set the delegate.
- (void) initializeInterstitial{
    
    self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMPInterstitialID];
    self.interstitial.delegate = self;
    
    // Begin a delayed load.
    [self delayedLoadInterstitial:kInitialInterstitialLoadDelay];           // Begin loading the interstitial with some delay.
    
}

// IB Action to show the interstitial.
- (IBAction)showAPSInterstitial:(id)sender {
    
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

- (void)MyAudienceBidder:(nonnull MyAudienceBidder *)bidder didFailBidFor:(nonnull id)adObject withError:(nonnull NSError *)err {
    
    // Call load on the updated MPInterstitialAdController
    [adObject loadAd];
    
    [self label_updateBidStatus:false];
    [self label_clearAttachedKW];


    
}

- (void)MyAudienceBidder:(nonnull MyAudienceBidder *)bidder didReceiveBidFor:(nonnull id)adObject {

        
    // Call load on the updated MPInterstitialAdController
    [adObject loadAd];
    
    [self label_updateBidStatus:true];
    [self label_updateAttachedKW:adObject];

        
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
        [self.interstitialWrapper loadMyBidsForInterstitialWithMopubAdObject:self.interstitial];
        [self indicator_showStateCurrentlyLoading];
    });
    
}


// Function that will submit a bid if bidding logic is enabled.
// If a bid is being submitted, the delegate function is responsible for calling 'loadAd'
// If there is no bid, loadAd will be invoked by this function instead.
- (void) loadInterstitial{
    
    [self.intAPSReadyIndicator setHidden:false];        // Hide indicator
    [self.intAPSReadyIndicator startAnimating];         // Start animation to indicate load cycle has begun.
    [self.showAPSInterstitialButton setHidden:true];

    
    [self.interstitialWrapper loadMyBidsForInterstitialWithMopubAdObject:self.interstitial];

    
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


- (void) indicator_showStateCurrentlyLoading{
    [self.intAPSReadyIndicator startAnimating];
    [self.intAPSReadyIndicator setHidden:false];
    [self.showAPSInterstitialButton setHidden:true];
}

- (void) indicator_showStateCurrentlyWaitingForShow{
    [self.intAPSReadyIndicator stopAnimating];
    [self.intAPSReadyIndicator setHidden:false];
    [self.showAPSInterstitialButton setHidden:false];
}

- (void) indicator_showStateCurrentlyWaitingForNextLoad{
    [self.intAPSReadyIndicator stopAnimating];
    [self.intAPSReadyIndicator setHidden:true];
    [self.showAPSInterstitialButton setHidden:true];
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




@end
