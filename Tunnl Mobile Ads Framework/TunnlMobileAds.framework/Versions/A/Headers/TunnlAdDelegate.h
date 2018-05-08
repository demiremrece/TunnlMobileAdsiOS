#ifndef TunnlAdDelegate_h
#define TunnlAdDelegate_h
#import <Foundation/Foundation.h>

@class TunnlAdDelegate;
@protocol AdDelegate <NSObject>

-(void) onAdReceived:(TunnlAdDelegate*) sender withData:(NSData*) data;
-(void) onAdStarted:(TunnlAdDelegate*) sender;
-(void) onAdClosed:(TunnlAdDelegate*) sender;
-(void) onAdFailedToLoad:(TunnlAdDelegate*) sender withData:(NSData*) data;
-(void) onAPINotReady:(TunnlAdDelegate*) sender withData:(NSData*) data;
-(void) onAPIReady:(TunnlAdDelegate*) sender;

@end

@interface TunnlAdDelegate : NSObject

@property (nonatomic, weak) id <AdDelegate> delegate;
-(void) dispatchEvent:(NSString*) event withData:(NSData*) data;

@end

#endif /* TunnlAdDelegate_h */
