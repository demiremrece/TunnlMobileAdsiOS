//
//  GDAd.m
//  GDApi
//
//  Created by Emre Demir on 30/12/16.
//  Copyright © 2016 Vooxe. All rights reserved.
//
@import GoogleMobileAds;
#import "AdStream.h"
#import <Foundation/Foundation.h>
#import <AdSupport/ASIdentifierManager.h>
#import <CommonCrypto/CommonDigest.h>
#import "TunnlAdDelegate.h"

@interface AdStream() <GADInterstitialDelegate,GADBannerViewDelegate>

@property(nonatomic,strong) NSString *unitId;
@property(nonatomic,strong) NSMutableArray *extras;
@property(nonatomic,strong) UIViewController *context;
@property(nonatomic, strong) DFPInterstitial *interstitial;
@property(nonatomic, strong) NSString *deviceID;

@end

@implementation AdStream

NSString * AD_RECEIVED = @"onAdReceived";
NSString * AD_FAILED_TO_LOAD = @"onAdFailedToLoad";
NSString * AD_CLOSED = @"onAdClosed";
NSString * AD_STARTED = @"onAdStarted";
NSString * API_NOT_READY = @"onAPINotReady";
NSString * API_IS_READY = @"onAPIReady";
NSString *bannerTestUnitId = @"/6499/example/banner";
NSString *interstitialTestUnitId = @"/6499/example/interstitial";
TunnlAdDelegate* eventDelegate;
NSArray* tunnlDatas;
int currentTunnlDataInd = -1;
BOOL isApiInitialized = false;
DFPBannerView *bannerView;
BOOL bannerActive = false;
int W_Banner;
int H_Banner;

-(id) init:(UIViewController *)context andWithDelegate:(TunnlAdDelegate*) eventlistener{
    
    self.context = context;
    isApiInitialized = true;
    
    if(eventlistener != nil){
        [self setDelegate:eventlistener];
    }
    return self;
}

-(void) requestBanner : (NSString *) size andAlinment:(NSString *)alignment andPositon:(NSString *)position{
    if(isApiInitialized){
        
        self.unitId = nil;
        self.extras = nil;
        
        if(tunnlDatas != nil){
            currentTunnlDataInd++;
            if(currentTunnlDataInd < [tunnlDatas count]){
                self.unitId = [[tunnlDatas objectAtIndex:currentTunnlDataInd] valueForKey:@"Adu"];
                self.extras = [[tunnlDatas objectAtIndex:currentTunnlDataInd] valueForKey:@"CustomParams"];
            }
        }
        
        if(self.unitId != nil){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                float X_Co;
                float Y_Co;
                
                bannerView = [[DFPBannerView  alloc] init ];
                bannerView.adUnitID = self.unitId;
                bannerView.delegate = self;
                bannerView.rootViewController = self.context;
                
                // size adjustment of banner
                if( [size  isEqual: @"320x50"]){
                    bannerView.adSize = kGADAdSizeBanner;
                    W_Banner = 320;
                    H_Banner = 50;
                }
                else if( [size  isEqual: @"320x100"]){
                    bannerView.adSize = kGADAdSizeLargeBanner;
                    W_Banner = 320;
                    H_Banner = 100;
                }
                else if( [size  isEqual: @"300x250"]){
                    bannerView.adSize = kGADAdSizeMediumRectangle;
                    W_Banner = 300;
                    H_Banner = 250;
                }
                else if( [size  isEqual: @"468x60"]){
                    bannerView.adSize = kGADAdSizeFullBanner;
                    W_Banner = 468;
                    H_Banner = 60;
                }
                else if( [size  isEqual: @"728x90"]){
                    bannerView.adSize = kGADAdSizeLeaderboard;
                    W_Banner = 728;
                    H_Banner = 90;
                }
                else{
                    bannerView.adSize = kGADAdSizeBanner;
                    W_Banner = 320;
                    H_Banner = 50;
                }
                //end of size adjustment
                
                // position of banner adjustment
                if([position isEqual:@"top"]){
                    Y_Co = 0;
                }
                else if([position isEqual:@"middle"]){
                    Y_Co = (self.context.view.frame.size.height - H_Banner) / 2;
                }
                else if([position isEqual:@"bottom"]){
                    Y_Co = self.context.view.frame.size.height - H_Banner;
                }
                // end of position adjustment
                
                // banner alignment adjustment
                if([alignment isEqual:@"left"]){
                    X_Co = 0;
                }
                else if([alignment isEqual:@"center"]){
                    X_Co = (self.context.view.frame.size.width - W_Banner) / 2;
                }
                else if([alignment isEqual:@"right"]){
                    X_Co = self.context.view.frame.size.width - W_Banner;
                }
                // end of alignment adjustment
                
                bannerView.frame = CGRectMake(X_Co, Y_Co, W_Banner, H_Banner);
                
                [self.context.view addSubview:bannerView];
                DFPRequest *request = [DFPRequest request];
                
                NSMutableDictionary* customTargets = [[NSMutableDictionary alloc] init];
                if([self.extras count] > 0){
                    
                    for( int i=0; i< [self.extras count]; i++ ){
                        NSMutableDictionary* tmpDic = (NSMutableDictionary*) [self.extras objectAtIndex:i];
                        [customTargets setValue:[tmpDic valueForKey:@"Value"] forKey:[tmpDic valueForKey:@"Key"]];
                    }
                    request.customTargeting = customTargets;
                }
                
                [bannerView loadRequest:request];
            });
            
            
        }
        
        
    }
    else{
        NSLog(@"VXAdApi is not initialized.");
    }
    
}

-(void) requestInterstitial{
    
    if(isApiInitialized){
        
        self.unitId = nil;
        self.extras = nil;
        
        if(tunnlDatas != nil){
            currentTunnlDataInd++;
            if(currentTunnlDataInd < [tunnlDatas count]){
                self.unitId = [[tunnlDatas objectAtIndex:currentTunnlDataInd] valueForKey:@"Adu"];
                self.extras = [[tunnlDatas objectAtIndex:currentTunnlDataInd] valueForKey:@"CustomParams"];
            }
        }
        
        if(self.unitId != nil){
            self.interstitial = [[DFPInterstitial alloc] initWithAdUnitID:self.unitId];
            self.interstitial.delegate = self;
            DFPRequest *request = [DFPRequest request];
            
            NSMutableDictionary* customTargets = [[NSMutableDictionary alloc] init];
            if([self.extras count] > 0){
                
                for( int i=0; i< [self.extras count]; i++ ){
                    NSMutableDictionary* tmpDic = (NSMutableDictionary*) [self.extras objectAtIndex:i];
                    [customTargets setValue:[tmpDic valueForKey:@"Value"] forKey:[tmpDic valueForKey:@"Key"]];
                }
                request.customTargeting = customTargets;
            }
            [self.interstitial loadRequest:request];
        }
        
    }
    else{
        NSLog(@"VXAdApi is not initialized.");
    }
}

-(void) destroyBanner{
    
    if(isApiInitialized){
        bannerView.hidden = YES;
    }
    else{
        NSLog(@"VXAdApi is not initialized.");
        
    }
}

-(TunnlAdDelegate*) delegate{
    return eventDelegate;
}

-(void) setDelegate:(TunnlAdDelegate *)del{
    
    eventDelegate = [[TunnlAdDelegate alloc] init];
    eventDelegate.delegate = del;
}

-(void) setTunnlData:(NSArray *)tunnlData{
    tunnlDatas = tunnlData;
}

-(void) addCustomTargeting:(NSString *)tag andValue:(NSString *)value{
    if(isApiInitialized){
        [self.extras setValue: value forKey: tag];
    }
    else{
        NSLog(@"TunnlMobileAds SDK is not initialized.");
    }
}

-(bool) isInitialized{
    if(isApiInitialized)
        return true;
    else
        return false;
}

// Called when an interstitial ad request succeeded.
- (void)interstitialDidReceiveAd:(DFPInterstitial *)ad {
    
    NSLog(@"interstitialDidReceiveAd");
    
    // inform tunnl we got ad
    NSString *targetUrl = [[tunnlDatas objectAtIndex:currentTunnlDataInd] valueForKey:@"Imp"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:targetUrl]];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
          
          NSLog(@"imp");
          
      }] resume];
    
    currentTunnlDataInd = -1; // reset index for further requests
    
    if (self.interstitial.isReady) {
        
        [self.interstitial presentFromRootViewController:self.context];
        
        NSArray *keys = [NSArray arrayWithObjects:@"adType",@"width",@"height", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"Interstitial",@"-1",@"-1", nil];
        NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects
                                                           forKeys:keys];
        NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:myData];
        
        [eventDelegate dispatchEvent:AD_RECEIVED withData:eventData];
        
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

// Called when an interstitial ad request failed.
- (void)interstitial:(DFPInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    
    if(currentTunnlDataInd < ([tunnlDatas count] - 1 )){
        [self requestInterstitial];
    }
    else{
        
        // inform tunnl we failed
        NSString *targetUrl = [[tunnlDatas objectAtIndex:currentTunnlDataInd] valueForKey:@"Err"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:targetUrl]];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
          ^(NSData * _Nullable data,
            NSURLResponse * _Nullable response,
            NSError * _Nullable error) {
              
              NSLog(@"imp error");
              
          }] resume];
        
        tunnlDatas = nil ; // set nil fur further ad requests.
        currentTunnlDataInd = -1;
        
        NSArray *keys = [NSArray arrayWithObjects:@"adType",@"error", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"Interstitial",[error localizedDescription], nil];
        NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects
                                                           forKeys:keys];
        NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:myData];
        
        [eventDelegate dispatchEvent:AD_FAILED_TO_LOAD withData:eventData];

        
    }
}

// Called just before presenting an interstitial.
- (void)interstitialWillPresentScreen:(DFPInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen");
    [eventDelegate dispatchEvent:AD_STARTED withData:nil];
}

// Called before the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(DFPInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen");
    
}

// Called just after dismissing an interstitial and it has animated off the screen.
- (void)interstitialDidDismissScreen:(DFPInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen");
    [eventDelegate dispatchEvent:AD_CLOSED withData:nil];
}

// Called just before the app will background or terminate because the user clicked on an
// ad that will launch another app (such as the App Store).
- (void)interstitialWillLeaveApplication:(DFPInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}

//*** for banner events

// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(DFPBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
    
    // inform tunnl we got ad
    NSString *targetUrl = [[tunnlDatas objectAtIndex:currentTunnlDataInd] valueForKey:@"Imp"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:targetUrl]];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
          
          NSLog(@"imp");
          
      }] resume];
    
    
    currentTunnlDataInd = -1; // reset index for further requests
    
    NSString* width; NSString* height;
    width = [NSString stringWithFormat:@"%d",W_Banner];
    height =[NSString stringWithFormat:@"%d",H_Banner];
    
    NSArray *keys = [NSArray arrayWithObjects:@"adType",@"width",@"height", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"Banner",width,height, nil];
    NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects
                                                       forKeys:keys];
    NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:myData];
    
    [eventDelegate dispatchEvent:AD_RECEIVED withData:eventData];
    
}

// Tells the delegate an ad request failed.
- (void)adView:(DFPBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    
    if(currentTunnlDataInd < ([tunnlDatas count] - 1 )){
        [self requestInterstitial];
    }
    else{
        
        // inform tunnl we failed
        NSString *targetUrl = [[tunnlDatas objectAtIndex:currentTunnlDataInd] valueForKey:@"Err"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:targetUrl]];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
          ^(NSData * _Nullable data,
            NSURLResponse * _Nullable response,
            NSError * _Nullable error) {
              
              NSLog(@"imp error");
              
          }] resume];
        
        tunnlDatas = nil ; // set nil fur further ad requests.
        currentTunnlDataInd = -1;
        
        NSArray *keys = [NSArray arrayWithObjects:@"adType",@"error", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"Banner",[error localizedDescription], nil];
        NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects
                                                           forKeys:keys];
        NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:myData];
        
        [eventDelegate dispatchEvent:AD_FAILED_TO_LOAD withData:eventData];
    }
    
    
    
}

// Tells the delegate that a full screen view will be presented in response
// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(DFPBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
    [eventDelegate dispatchEvent:AD_STARTED withData:nil];
}

// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(DFPBannerView *)adView {
}

// Tells the delegate that the full screen view has been dismissed.
- (void)adViewDidDismissScreen:(DFPBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
    [eventDelegate dispatchEvent:AD_CLOSED withData:nil];
}

// Tells the delegate that a user click will open another app (such as
// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(DFPBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}

@end

