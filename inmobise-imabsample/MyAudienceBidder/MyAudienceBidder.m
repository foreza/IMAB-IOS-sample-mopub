 //
//  MyAudienceBidder.m
//

#import "MyAudienceBidder.h"

#import "MoPub.h"
#import <InMobiSDK/InMobiSDK.h>
#import <DTBiOSSDK/DTBiOSSDK.h>

typedef NS_ENUM(NSUInteger, ABAdType) {
    kABAdTypeUnknown = 0,
    kABAdTypeBanner = 1,
    kABAdTypeInterstitial = 2,
    kABAdTypeVideo = 3
};

@interface MyAudienceBidder () <IMAudienceBidderDelegate, DTBAdCallback>

@property (nonatomic, weak) id<MyAudienceBidderDelegate> delegate;

@property (nonatomic, strong) MPAdView* mopubBanner;
@property (nonatomic, strong) MPInterstitialAdController* mopubInterstitial;
@property (nonatomic, strong) IMBidObject* bidObject;

@property (nonatomic, strong) NSString* IMPlacementId;
@property (nonatomic) ABAdType adType;

@property (nonatomic, strong) DTBAdSize* A9Size;
@property (nonatomic, strong) NSString* A9SlotId;

@property (nonatomic, strong) NSTimer* timeoutTimer;
@property (nonatomic) NSTimeInterval totalTimeout;

@property (nonatomic) NSInteger requestedWidth;
@property (nonatomic) NSInteger requestedHeight;
@property (nonatomic) BOOL isIMTemporaryBidAvailable;
@property (nonatomic) BOOL isIMBidSuccess;
@property (nonatomic) BOOL isABCycleFinished;
@property (nonatomic) BOOL isRefreshBid;

@end

@implementation MyAudienceBidder

- (instancetype)initWithDelegate:(id<MyAudienceBidderDelegate>)delegate {
    if(self = [super init]) {
        _delegate = delegate;
        _adType = kABAdTypeUnknown;
        _totalTimeout = 0.0;
        [self resetState];
    }
    return self;
}

- (void)resetState{
    _isABCycleFinished = NO;
    _isIMTemporaryBidAvailable = NO;
    _isIMBidSuccess = NO;
}

- (void)setIMPLCID:(NSString *)IMPLCID {
    _IMPlacementId = IMPLCID;
}

- (void)setTimeout:(double)seconds {
    _totalTimeout = seconds;
}

- (void)setA9AppKey:(NSString*)appKey {
    [[DTBAds sharedInstance] setAppKey:appKey];
    [[DTBAds sharedInstance] setTestMode:kAPS_TEST_MODE];
}

- (void)setA9UUID:(NSString *)A9SLOTID {
    _A9SlotId = A9SLOTID;
}

#pragma mark - Report Error

- (void)reportErrorForAd:(id)adObj withMsg:(NSString*)errMsg {
    NSError* err = [NSError errorWithDomain:NSStringFromClass([MyAudienceBidder class])
                                       code:100
                                   userInfo:@{NSLocalizedDescriptionKey : errMsg}];
    [self.delegate MyAudienceBidder:self didFailBidFor:adObj withError:err];
}

#pragma mark - Timeout Methods

- (void)MarkABFinishedWithMopubAdObject:(id)adObj{
    [self.timeoutTimer invalidate];
    self.isABCycleFinished = YES;
    if(self.isIMBidSuccess||self.isIMTemporaryBidAvailable){
        //Fire Success Callback
        [self.delegate MyAudienceBidder:self didReceiveBidFor:adObj];
    } else {
        //Fire Fail Callback
        NSString* errMsg = @"Audience bidder did not prepare a bid in time";
        [self reportErrorForAd:adObj withMsg:errMsg];
    }
}

- (void)invokeTimeout:(NSTimer*)theTimer {
    if(!self.isABCycleFinished){
       [self MarkABFinishedWithMopubAdObject:(id)[theTimer userInfo]];
    } else {
        [self.timeoutTimer invalidate];
    }
}

- (void)startTimeoutTimerWithMopubObject:(id)adObj {
    if(self.totalTimeout != 0.0) {
        if(self.totalTimeout < 3.0){
            self.totalTimeout = 3.0;
        }
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:self.totalTimeout
                                                             target:self
                                                           selector:@selector(invokeTimeout:)
                                                           userInfo:adObj
                                                            repeats:NO];
    } else {
        [self invokeTimeout:nil];
    }
}

- (NSTimeInterval)calculateRemainingTime {
    NSTimeInterval remainingTime = [self.timeoutTimer.fireDate timeIntervalSinceDate:[NSDate date]];
    [self.timeoutTimer invalidate];
    if(remainingTime < 0) {
        remainingTime = 0;
    }
    return remainingTime;
}

#pragma mark - Load Bid Methods

- (void)submitBannerBid {
    NSTimeInterval remainingTime = [self calculateRemainingTime];
    if(!self.bidObject || !self.isRefreshBid) {
        self.bidObject = [IMAudienceBidder createBidForAdType:kIMBiddingAdTypeBanner
                                                withPlacement:self.IMPlacementId
                                                        adObj:self.mopubBanner
                                                    bidWindow:remainingTime
                                                  andDelegate:self];
    }
    [self.bidObject submitBid];
}

- (void)submitInterstitialBid {
    NSTimeInterval remainingTime = [self calculateRemainingTime];
    if(!self.bidObject || !self.isRefreshBid) {
        self.bidObject = [IMAudienceBidder createBidForAdType:kIMBiddingAdTypeInterstitial
                                                withPlacement:self.IMPlacementId
                                                        adObj:self.mopubInterstitial
                                                    bidWindow:remainingTime
                                                  andDelegate:self];
    }
    [self.bidObject submitBid];
}

- (void)submitBid {
    [self resetState];
    switch(self.adType) {
        case kABAdTypeBanner:
            [self submitBannerBid];
            break;
        case kABAdTypeInterstitial:
        case kABAdTypeVideo:
            [self submitInterstitialBid];
            break;
        case kABAdTypeUnknown:
        default: {
            NSString* errMsg = @"Unknown ad type, no bid was submitted";
            [self reportErrorForAd:nil withMsg:errMsg];
            break;
        }
    }
}

- (void)loadA9 {
    DTBAdLoader* a9Loader = [DTBAdLoader new];
    [a9Loader setSizes:self.A9Size, nil];
    [a9Loader loadAd:self];
}

- (void)loadMyBidsForBannerWithMopubAdObject:(id)adObj width:(NSInteger)width height:(NSInteger)height {
    [self resetState];
    [self startTimeoutTimerWithMopubObject:adObj];
    _adType = kABAdTypeBanner;
    _isRefreshBid = NO;
    _requestedWidth = width;
    _requestedHeight = height;
    _mopubBanner = (MPAdView*)adObj;
    
    if(self.A9SlotId) {
        // load A9 banner
        self.A9Size = [[DTBAdSize alloc] initBannerAdSizeWithWidth:width
                                                            height:height
                                                       andSlotUUID:self.A9SlotId];
        [self loadA9];
    } else {
        [self submitBannerBid];
    }
}

- (void)loadMyBidsForInterstitialWithMopubAdObject:(id)adObj {
    [self resetState];
    [self startTimeoutTimerWithMopubObject:adObj];
    _adType = kABAdTypeInterstitial;
    _isRefreshBid = NO;
    _mopubInterstitial = (MPInterstitialAdController*)adObj;
    
    if(self.A9SlotId) {
        // load A9 interstitial
        self.A9Size = [[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID:self.A9SlotId];
        [self loadA9];
    } else {
        [self submitInterstitialBid];
    }
}

- (void)loadMyBidsForVideoWithMopubAdObject:(id)adObj width:(NSInteger)width height:(NSInteger)height {
    [self resetState];
    [self startTimeoutTimerWithMopubObject:adObj];
    _adType = kABAdTypeVideo;
    _isRefreshBid = NO;
    _requestedWidth = width;
    _requestedHeight = height;
    _mopubInterstitial = (MPInterstitialAdController*)adObj;
    
    if(self.A9SlotId) {
        //load A9 video
        self.A9Size = [[DTBAdSize alloc] initVideoAdSizeWithPlayerWidth:width
                                                                 height:height
                                                            andSlotUUID:self.A9SlotId];
        [self loadA9];
    } else {
        [self submitInterstitialBid];
    }
}

- (void)refreshBid {
    self.isRefreshBid = YES;
    if(self.A9SlotId) {
        [self loadA9];
    } else {
        [self.bidObject submitBid];
    }
}

#pragma mark - IMAudienceBidderDelegate Protocol Methods

- (void)audienceBidderDidReceiveBidFor:(id)adObject {
    NSLog(@"Successfully loaded IM Bid");
    self.isIMBidSuccess = YES;
    if(!self.isABCycleFinished) {
        [self MarkABFinishedWithMopubAdObject:adObject];
    }
}

- (void)audienceBidderDidFailBidFor:(id)adObject withError:(NSError*)error {
    NSLog(@"Failed to load IM Bid");
    self.isIMBidSuccess = NO;
    if(!self.isABCycleFinished) {
        [self MarkABFinishedWithMopubAdObject:adObject];
    }
}

#pragma mark - DTBAdCallback Protocol Methods

- (void)onSuccess:(DTBAdResponse*)adResponse {
    NSLog(@"Succesfully loaded A9 ad");
    [IMAudienceBidder submitExternalBid:adResponse withPlacement:self.IMPlacementId];
    [self submitBid];
    self.isIMTemporaryBidAvailable = YES;
}

- (void)onFailure:(DTBAdError)error {
    NSLog(@"Failed to load A9 ad");
    [self submitBid];
}

@end
