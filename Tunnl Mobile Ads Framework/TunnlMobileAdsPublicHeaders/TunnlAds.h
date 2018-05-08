//
//  TunnlAds.h
//  TunnlMobileAds
//
//  Created by Emre Demir on 7.05.2018.
//  Copyright © 2018 Vooxe. All rights reserved.
//

#ifndef TunnlAds_h
#define TunnlAds_h
#import "AdStream.h"


@interface TunnlAds :NSObject

@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSMutableArray *arrNeighboursData;
@property (nonatomic, strong) NSMutableDictionary *dictTempDataStorage;
@property (nonatomic, strong) NSMutableString *foundValue;
@property (nonatomic, strong) NSString *currentElement;

+(AdStream*) adStream;
+(NSString*) bundleId;
+(void) init:(NSString*) bundleId;
+(void) RequestInterstitialAd;
+(void) RequestBannerAd:(NSString*) adsize withAlignment:(NSString*) alignment withPosition:(NSString*) position;
+(void) addEventListener:(TunnlAdDelegate*) sender;
+(void) closeBanner;
+(void) showAd:(Boolean)isInterstitial withSize:(NSString *)adsize withAlignment:(NSString *)alignment withPosition:(NSString *)position;

@end

#endif /* TunnlAds_h */
