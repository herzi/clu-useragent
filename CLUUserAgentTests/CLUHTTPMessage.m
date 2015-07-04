//
//  CLUHTTPMessage.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 04.07.15.
//
//

#import "CLUHTTPMessage.h"

// TODO: When porting to Swift, these can become a String-based enumeration.
NSString* const kHTTPHeaderNameContentLength = @"Content-Length";
NSString* const kHTTPHeaderNameUserAgent = @"User-Agent";
/* TODO: When porting to Swift, this can become an enum:
 * enum HTTPStatus : (Int, String) {
 *   case OK(200, "OK")
 * }
 */
NSUInteger const kHTTPStatusCodeOK = 200;
static NSDictionary* kHTTPStatusMessages = nil;

@interface CLUHTTPMessage ()

@end

@implementation CLUHTTPMessage

#pragma mark Life Cycle Management

+ (void)initialize
{
    static dispatch_once_t onceToken;
    
    [super initialize];
    
    dispatch_once(&onceToken, ^{
        kHTTPStatusMessages = @{@(kHTTPStatusCodeOK): @"OK"};
    });
}

#pragma mark HTTP Utilities

+ (nonnull NSString *)statusMessageForCode:(NSUInteger)statusCode
{
    NSString* result = kHTTPStatusMessages[@(statusCode)];
    
    if (!result) {
        // FIXME: Throw a proper exception. However, always throw an exception in this case.
        @throw [NSException exceptionWithName:@"FIXME" reason:@"Provide a better exception here." userInfo:nil];
    }
    
    return result;
}

@end
