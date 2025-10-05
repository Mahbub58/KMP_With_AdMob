

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoogleMobileAdsConsentManager : NSObject

@property(class, atomic, readonly, strong, nonnull) GoogleMobileAdsConsentManager *sharedInstance;
@property(nonatomic, readonly) BOOL canRequestAds;
@property(nonatomic, readonly) BOOL isPrivacyOptionsRequired;

- (void)gatherConsentFromConsentPresentationViewController:(UIViewController *)viewController
                                  consentGatheringComplete:
                                          (void (^)(NSError *_Nullable error))completionHandler;

- (void)presentPrivacyOptionsFormFromViewController:(UIViewController *)viewController
                                  completionHandler:
                                          (void (^)(NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END