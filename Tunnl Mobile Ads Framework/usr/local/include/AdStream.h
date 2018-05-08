//
//  GDAd.h
//  GDApi
//
//  Created by Emre Demir on 30/12/16.
//  Copyright © 2016 Vooxe. All rights reserved.
//

#ifndef AdStream_h
#define AdStream_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TunnlAdDelegate.h"


@interface AdStream : NSObject
-(id) init:(UIViewController *) context andWithDelegate:(TunnlAdDelegate*) eventlistener;
-(void) requestInterstitial;
-(void) requestBanner: (NSString *) size andAlinment:(NSString*) alignment andPositon:(NSString *)position;
-(void) addCustomTargeting:(NSString *) tag andValue:(NSString*) value;
-(void) destroyBanner;
-(TunnlAdDelegate*) delegate;
-(void) setDelegate:(TunnlAdDelegate*) del;
-(void) setTunnlData:(NSArray*) tunnlData;
@end


#endif /* AdStream_h */
