#import <Foundation/Foundation.h>
#import "TunnlAdDelegate.h"

@implementation TunnlAdDelegate

@synthesize delegate;

-(void) dispatchEvent:(NSString*) event withData:(NSData*) data{

    if([event isEqualToString:@"onAdReceived"]){
        [self.delegate onAdReceived:self withData:data];
    }
    else if([event isEqualToString:@"onAdStarted"]){
        [self.delegate onAdStarted:self];
    }
    else if([event isEqualToString:@"onAdClosed"]){
        [self.delegate onAdClosed:self];
    }
    else if([event isEqualToString:@"onAdFailedToLoad"]){
        [self.delegate onAdFailedToLoad:self withData:data];
    }
    else if([event isEqualToString:@"onAPINotReady"]){
        [self.delegate onAPINotReady:self withData:data];
    }
    else if([event isEqualToString:@"onAPIReady"]){
        [self.delegate onAPIReady:self];
    }
}
@end
