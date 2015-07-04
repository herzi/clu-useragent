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

extern NSString* const kHTTPMethodGet;

extern NSUInteger const kHTTPStatusCodeOK;

extern NSString* const kHTTPVersion1_1;

@interface CLUHTTPMessage : NSObject

+ (instancetype) messageForEmptyRequest;
+ (instancetype) responseWithStatusCode:(NSUInteger)statusCode HTTPVersion:(NSString*)HTTPVersion;
+ (instancetype) responseWithStatusCode:(NSUInteger)statusCode statusMessage:(NSString*)statusMessage HTTPVersion:(NSString*)HTTPVersion;

+ (NSString*)statusMessageForCode:(NSUInteger)statusCode;

@property (readonly) NSDictionary* allHTTPHeaderFields; // NSDictionary<NSString*,NSString*>*
@property (getter=isHeaderComplete, readonly) BOOL headerComplete;
@property NSData* HTTPBody;
@property (readonly) NSString* HTTPMethod;
@property (readonly) NSString* HTTPVersion;
@property (readonly) CFHTTPMessageRef underlyingMessage;
@property (readonly) NSURL* URL;

- (NSRange) rangeOfAppendedDataFrom:(NSData*)data;
- (NSData*) serializedData;
- (void) setValue:(NSString*)value forHTTPHeaderField:(NSString*)field;

@end

NS_ASSUME_NONNULL_END
