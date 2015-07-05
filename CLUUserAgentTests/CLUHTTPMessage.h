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
extern NSString* const kHTTPHeaderNameContentType;
extern NSString* const kHTTPHeaderNameUserAgent;

extern NSString* const kHTTPHeaderValueConnectionKeepAlive;

extern NSString* const kHTTPMethodGet;

/* TODO: When porting to Swift, this can become an enum:
 * enum HTTPStatus : (Int, String) {
 *   case OK(200, "OK")
 * }
 */
typedef NS_ENUM(NSUInteger, HTTPStatusCode) {
    // success
    kHTTPStatusCodeOK = 200,
    
    // request problem
    kHTTPStatusCodeBadRequest = 400,
    kHTTPStatusCodeNotFound = 404,
    kHTTPStatusCodeMethodNotAllowed, // 405
    
    // server problem
    kHTTPStatusCodeHTTPVersionNotSupported = 505
};

typedef NS_ENUM(NSUInteger, CLUHTTPMessageType) {
    kCLUHTTPMessageTypeRequest,
    kCLUHTTPMessageTypeResponse
};

extern NSString* const kHTTPVersion1_1;

extern NSString* const kMIMETypeUTF8Text;

@interface CLUHTTPMessage : NSObject

+ (instancetype) messageForEmptyRequest;
+ (instancetype) responseWithStatusCode:(NSUInteger)statusCode HTTPVersion:(NSString*)HTTPVersion;
+ (instancetype) responseWithStatusCode:(NSUInteger)statusCode statusMessage:(NSString*)statusMessage HTTPVersion:(NSString*)HTTPVersion;

+ (NSString*)statusMessageForCode:(HTTPStatusCode)statusCode;

@property (readonly) NSDictionary* allHTTPHeaderFields; // NSDictionary<NSString*,NSString*>*
@property (getter=isHeaderComplete, readonly) BOOL headerComplete;
@property NSData* HTTPBody;
@property (readonly) NSString* HTTPMethod;
@property (readonly) NSString* HTTPVersion;
@property (readonly) CLUHTTPMessageType messageType;
@property (readonly) CFHTTPMessageRef underlyingMessage;
@property (readonly) NSURL* URL;

- (NSRange) rangeOfAppendedDataFrom:(NSData*)data;
- (NSData*) serializedData;
- (void) setValue:(NSString*)value forHTTPHeaderField:(NSString*)field;
- (nullable NSString*) valueForHTTPHeaderField:(NSString*)headerField;

@end

NS_ASSUME_NONNULL_END
