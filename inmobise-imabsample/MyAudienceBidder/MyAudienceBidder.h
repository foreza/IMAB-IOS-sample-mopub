//
//  MyAudienceBidder.h
//

#import <Foundation/Foundation.h>

#define kAPS_TEST_MODE 1

NS_ASSUME_NONNULL_BEGIN

@protocol MyAudienceBidderDelegate;

@interface MyAudienceBidder: NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(id<MyAudienceBidderDelegate>)delegate;

- (void)setIMPLCID:(NSString*)IMPLCID;
- (void)setTimeout:(double)seconds;

- (void)setA9AppKey:(NSString*)appKey;
- (void)setA9UUID:(NSString*)A9SLOTID;

- (void)loadMyBidsForBannerWithMopubAdObject:(id)adObj width:(NSInteger)width height:(NSInteger)height;
- (void)loadMyBidsForInterstitialWithMopubAdObject:(id)adObj;
- (void)loadMyBidsForVideoWithMopubAdObject:(id)adObj width:(NSInteger)width height:(NSInteger)height;
- (void)refreshBid;

@end

@protocol MyAudienceBidderDelegate <NSObject>

- (void)MyAudienceBidder:(MyAudienceBidder*)bidder didReceiveBidFor:(id)adObject;
- (void)MyAudienceBidder:(MyAudienceBidder*)bidder didFailBidFor:(id)adObject withError:(NSError*)err;

@end

NS_ASSUME_NONNULL_END
