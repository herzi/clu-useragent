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

extern NSString* const kHTTPHeaderNameConnection;
extern NSString* const kHTTPHeaderNameContentLength;
extern NSString* const kHTTPHeaderNameUserAgent;

extern NSString* const kHTTPHeaderValueConnectionKeepAlive;

extern NSUInteger const kHTTPStatusCodeOK;

@interface CLUHTTPMessage : NSObject

+ (instancetype) messageForEmptyRequest;

+ (NSString*)statusMessageForCode:(NSUInteger)statusCode;

@property (readonly) NSData* body;
@property (readonly) CFHTTPMessageRef underlyingMessage;

- (NSRange) rangeOfAppendedDataFrom:(NSData*)data;

@end

NS_ASSUME_NONNULL_END
