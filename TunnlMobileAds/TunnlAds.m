//  GDLogger.m
//  gdapi
//
//  Created by Emre Demir on 19/12/16.
//  Copyright © 2016 Emre Demir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TunnlAds.h"
#import "AdStream.h"
#import "TunnlAdPosition.h"
#import "TunnlAlignment.h"
#import "TunnlAdSize.h"
#import "TunnlAdDelegate.h"
#import "Reachability.h"

@implementation TunnlAds

static AdStream* adStream;
NSMutableArray* elementsArray;
NSString* currentString;
NSString* bundleId;
TunnlAdDelegate* delegate;

+(void) init:(NSString *)bundle
{
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    bundleId = bundle;
    
    if(status == NotReachable)
    {
        [self initTunnlApi];
        
        if([self adStream].delegate != nil){
            NSArray *keys = [NSArray arrayWithObjects:@"error", nil];
            NSArray *objects = [NSArray arrayWithObjects:@"API cannot connect to internet. Please check the network connection.", nil];
            NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects
                                                               forKeys:keys];
            NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:myData];
            
            [[self adStream].delegate dispatchEvent:@"onAPINotReady" withData:eventData];
        }
    }
}

+(void) initTunnlApi{
    if(adStream == nil){
        UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        adStream = [[AdStream alloc] init:rootViewController andWithDelegate:delegate];
    }
}

+(AdStream*) adStream{
    return adStream;
}

+(NSString*) bundleId{
    return bundleId;
}

+(void) RequestInterstitialAd{
    
    if(adStream != nil){
        
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if(status != NotReachable)
        {
            [self showAd:true withSize:nil withAlignment:nil withPosition:nil];
        }
        else{
            // no internet connection
            if([self adStream].delegate != nil){
                NSArray *keys = [NSArray arrayWithObjects:@"error", nil];
                NSArray *objects = [NSArray arrayWithObjects:@"API cannot connect to internet. Please check the network connection.", nil];
                NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects
                                                                   forKeys:keys];
                NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:myData];
                
                [[self adStream].delegate dispatchEvent:@"onAdFailedToLoad" withData:eventData];
            }
        }
    }
    else{
        NSLog(@"Api is not initialized!");
    }
}

+(void) RequestBannerAd:(NSString *)adsize withAlignment:(NSString *)alignment withPosition:(NSString *)position{
    
    if(adStream != nil){
        
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if(status != NotReachable){
            [self showAd:false withSize:adsize withAlignment:alignment withPosition:position];
        }
        else{
            if([self adStream].delegate != nil){
                NSArray *keys = [NSArray arrayWithObjects:@"error", nil];
                NSArray *objects = [NSArray arrayWithObjects:@"API cannot connect to internet. Please check the network connection.", nil];
                NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects
                                                                   forKeys:keys];
                NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:myData];
                
                [[self adStream].delegate dispatchEvent:@"onAdFailedToLoad" withData:eventData];
            }
        }
    }
    else{
        NSLog(@"Api is not initialized!");
    }
}

+(void) showAd:(Boolean)isInterstitial withSize:(NSString *)adsize withAlignment:(NSString *)alignment withPosition:(NSString *)position{
    
    if(adStream != nil){
        NSString *msize = @"interstitial";
        
        if(!isInterstitial){
            msize = adsize;
        }
        NSString * timeStampValue = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        NSString *targetUrl = [NSString stringWithFormat:@"https://pub.tunnl.com/oppm?bundleid=ios.%@&msize=%@&correlator=%@",[self bundleId],msize, timeStampValue];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:targetUrl]];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
          ^(NSData * _Nullable data,
            NSURLResponse * _Nullable response,
            NSError * _Nullable error) {
              
              if(error == nil){
                  NSDictionary* res = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:kNilOptions
                                                                        error:&error];
                  if(error == nil){
                      NSArray *tunnlData = [res objectForKey:@"Items"];
                      [adStream setTunnlData:tunnlData];
                      
                      if([tunnlData count] > 0){
                          if(isInterstitial){
                              [adStream requestInterstitial];
                          }
                          else{
                              [adStream requestBanner:adsize andAlinment:alignment andPositon:position];
                          }
                      }
                      else{
                          NSArray *keys = [NSArray arrayWithObjects:@"error", nil];
                          NSArray *objects = [NSArray arrayWithObjects: @"Game data is empty.", nil];
                          NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects
                                                                             forKeys:keys];
                          NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:myData];
                          
                          [[self adStream].delegate dispatchEvent:@"onAdFailedToLoad" withData:eventData];
                      }
                      
                  }
                  else{
                      NSArray *keys = [NSArray arrayWithObjects:@"error", nil];
                      NSArray *objects = [NSArray arrayWithObjects: @"Something went wrong parsing game data.", nil];
                      NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects
                                                                         forKeys:keys];
                      NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:myData];
                      
                      [[self adStream].delegate dispatchEvent:@"onAdFailedToLoad" withData:eventData];
                  }
              }
              else{
                  NSArray *keys = [NSArray arrayWithObjects:@"error", nil];
                  NSArray *objects = [NSArray arrayWithObjects: @"Something went wrong fetching game data.", nil];
                  NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects
                                                                     forKeys:keys];
                  NSData* eventData = [NSKeyedArchiver archivedDataWithRootObject:myData];
                  
                  [[self adStream].delegate dispatchEvent:@"onAdFailedToLoad" withData:eventData];
              }
              
          }] resume];
    }
}

+(void) closeBanner{
    if(adStream != nil){
        [adStream destroyBanner];
    }
    else{
        NSLog(@"Api is not initialized!");
    }
}

+(void) addEventListener:(TunnlAdDelegate *)sender{
    delegate = sender;
}

@end
