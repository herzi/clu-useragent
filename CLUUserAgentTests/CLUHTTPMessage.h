//
//  CLUHTTPMessage.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 04.07.15.
//
//

#import <Foundation/Foundation.h>
#import <CLUUserAgent/CLUMacros.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const kHTTPHeaderNameContentLength;
extern NSString* const kHTTPHeaderNameUserAgent;

extern NSUInteger const kHTTPStatusCodeOK;

@interface CLUHTTPMessage : NSObject

+ (NSString*)statusMessageForCode:(NSUInteger)statusCode;

@end

NS_ASSUME_NONNULL_END
