//
//  CLUHTTPMessage.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 04.07.15.
//
//

#import "CLUHTTPMessage.h"

// TODO: When porting to Swift, these can become a String-based enumeration.
NSString* const kHTTPHeaderNameConnection = @"Connection";
NSString* const kHTTPHeaderNameContentLength = @"Content-Length";
NSString* const kHTTPHeaderNameContentType = @"Content-Type";
NSString* const kHTTPHeaderNameUserAgent = @"User-Agent";

// TODO: When porting to Swift, these can become a String-based enumeration.
NSString* const kHTTPHeaderValueConnectionKeepAlive = @"keep-alive";

NSString* const kHTTPMethodGet = @"GET";

NSString* const kHTTPVersion1_1 = @"HTTP/1.1"; // FIXME: Add Unit-Test to compare with kCFHTTPVersion1_1.

NSString* const kMIMETypeUTF8Text = @"text/plain; charset=UTF-8";

static NSDictionary* kHTTPStatusMessages = nil;

NS_ASSUME_NONNULL_BEGIN

@interface CLUHTTPMessage ()

#warning FIXME: Consider toll-free bridging instead of wrapping: https://web.archive.org/web/20111013023821/http://cocoadev.com/index.pl?HowToCreateTollFreeBridgedClass and http://www.opensource.apple.com/source/CFNetwork/CFNetwork-129.10/HTTP/CFHTTPMessage.c
@property CFHTTPMessageRef underlyingMessage;

@end

NS_ASSUME_NONNULL_END

@implementation CLUHTTPMessage

#warning FIXME: Take a look at the CFHTTPMessage API and make sure every feature is covered here.

#pragma mark Life Cycle Management

+ (nonnull instancetype)messageForEmptyRequest
{
    CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, YES);
    return [[self alloc] __initWithUnderlyingMessage:message];
}

+ (nonnull instancetype)responseWithStatusCode:(NSUInteger)statusCode HTTPVersion:(nonnull NSString*)HTTPVersion
{
    return [self responseWithStatusCode:statusCode
                          statusMessage:[self statusMessageForCode:statusCode]
                            HTTPVersion:HTTPVersion];
}

+ (nonnull instancetype)responseWithStatusCode:(NSUInteger)statusCode statusMessage:(nonnull NSString*)statusMessage HTTPVersion:(nonnull NSString*)HTTPVersion
{
    CFHTTPMessageRef message = CFHTTPMessageCreateResponse(kCFAllocatorDefault, statusCode,
                                                           (__bridge CFStringRef)statusMessage,
                                                           (__bridge CFStringRef)HTTPVersion);
    return [[self alloc] __initWithUnderlyingMessage:message];
}

- (instancetype) __initWithUnderlyingMessage:(CFHTTPMessageRef)underlyingMessage
{
    CLUHTTPMessage* result = [[CLUHTTPMessage alloc] init];
    result.underlyingMessage = underlyingMessage;
    return result;
}

- (void)dealloc
{
    if (self.underlyingMessage) {
        CFRelease(self.underlyingMessage);
    }
}

#pragma mark Inspecting the Message

- (nonnull NSDictionary*) allHTTPHeaderFields
{
    NSDictionary* result = (__bridge_transfer NSDictionary*)CFHTTPMessageCopyAllHeaderFields(self.underlyingMessage);
    NSAssert(result, nil);
    return result;
}

- (nonnull NSData *)HTTPBody
{
    NSData* result = (__bridge_transfer NSData*)CFHTTPMessageCopyBody(self.underlyingMessage);
    NSAssert(result, nil);
    
    if (self.messageType == kCLUHTTPMessageTypeRequest) {
        NSAssert(self.headerComplete, nil);
        
        NSString* contentLength = [self valueForHTTPHeaderField:kHTTPHeaderNameContentLength];
        NSUInteger expected;
        if (contentLength) {
            expected = contentLength.integerValue;
        } else if ([kHTTPMethodGet isEqualToString:self.HTTPMethod]) {
            expected = 0;
        } else {
#warning FIXME: Write a unit test using the chunked encoding.
#warning FIXME: Read the HTTP specifications to check the correct behavior for neither Content-Length nor Transfer-Encoding.
            @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement!" userInfo:nil];
        }
        NSAssert(result.length >= expected, nil);
    }
    
    return result;
}

- (nonnull NSString*)HTTPMethod
{
    NSString* result = (__bridge_transfer NSString*)CFHTTPMessageCopyRequestMethod(self.underlyingMessage);
    NSAssert(result, nil);
    return result;
}

- (nonnull NSString*)HTTPVersion
{
    NSString* result = (__bridge_transfer NSString*)CFHTTPMessageCopyVersion(self.underlyingMessage);
    NSAssert(result, nil);
    return result;
}

- (BOOL)isHeaderComplete
{
    return CFHTTPMessageIsHeaderComplete(self.underlyingMessage);
}

- (CLUHTTPMessageType)messageType
{
    return CFHTTPMessageIsRequest(self.underlyingMessage) ? kCLUHTTPMessageTypeRequest : kCLUHTTPMessageTypeResponse;
}

- (nonnull NSData*)serializedData
{
    NSData* result = (__bridge_transfer NSData*)CFHTTPMessageCopySerializedMessage(self.underlyingMessage);
    NSAssert(result, nil);
    return result;
}

- (nonnull NSURL*)URL
{
    NSURL* result = (__bridge_transfer NSURL*)CFHTTPMessageCopyRequestURL(self.underlyingMessage);
    NSAssert(result, nil);
    return result;
}

- (nullable NSString*) valueForHTTPHeaderField:(nonnull NSString*)headerField
{
    return (__bridge_transfer NSString*)CFHTTPMessageCopyHeaderFieldValue(self.underlyingMessage,
                                                                          (__bridge CFStringRef)headerField);
}

#pragma mark Mutation

#warning FIXME: Move this into CLUMutableHTTPMessage

- (void)setHTTPBody:(nonnull NSData*)HTTPBody
{
    CFHTTPMessageSetBody(self.underlyingMessage, (__bridge CFDataRef)HTTPBody);
}

- (void) setValue:(nonnull NSString*)value forHTTPHeaderField:(nonnull NSString*)field
{
    CFHTTPMessageSetHeaderFieldValue(self.underlyingMessage,
                                     (__bridge CFStringRef)field,
                                     (__bridge CFStringRef)value);
}

#pragma mark HTTP Parsing

- (NSRange)rangeOfAppendedDataFrom:(nonnull NSData*)data
{
    NSUInteger __block length = 0;
    
#warning FIXME: Start to unit-test this method.
    /* For Unit-Testing:
     * According to https://developer.apple.com/library/ios/releasenotes/Foundation/RN-Foundation/#//apple_ref/doc/uid/TP30000742-CH2-SW36, dispatch_data_t can be safely cast to NSData*. So,
     * for testing, we can create our test data using dispatch_data_create_concat()
     * and then pass it to this method.
     */
    CLU_WEAKEN(self);
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        CLU_STRENGTHEN(self);
        NSAssert(self, nil);
        
        if (!self.headerComplete) {
            // check if we can find the end of the headers in this chunk
            char const* str = bytes;
            char const* pattern = "\r\n\r\n";
            char const* end = strnstr(str, pattern, byteRange.length);
            if (end) {
                end += strlen(pattern);
                BOOL passed = CFHTTPMessageAppendBytes(self.underlyingMessage, bytes, end - str);
                if (passed) {
                    if (end - str < byteRange.length) {
                        @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement! (Parse the remainder of `bytes`.)" userInfo:nil];
                    } else {
                        // all is parsed
                        length += byteRange.length;
                        return;
                    }
                } else {
                    @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement! (Not passed, create an error.)" userInfo:nil];
                }
            } else {
                @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement! (Send everything to the `CFHTTPMessage`.)" userInfo:nil];
            }
        } else {
            @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement! (Try to calculate from the headers how much data is expected, pass on as much as required.)" userInfo:nil];
        }
    }];
    
    return NSMakeRange(0, length);
}

#pragma mark HTTP Utilities

+ (nonnull NSString *)statusMessageForCode:(HTTPStatusCode)statusCode
{
    switch (statusCode) {
            
        case kHTTPStatusCodeOK: // 200
            return @"OK";
            
        case kHTTPStatusCodeBadRequest: // 400
            return @"Bad Request";
            
        case kHTTPStatusCodeNotFound: // 404
            return @"Not Found";
            
        case kHTTPStatusCodeMethodNotAllowed: // 405
            return @"Method Not Allowed";
            
        case kHTTPStatusCodeHTTPVersionNotSupported: // 505
            return @"HTTP Version Not Supported";
            
    }
}

@end
