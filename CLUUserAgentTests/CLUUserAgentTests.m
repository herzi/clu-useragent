//
//  CLUUserAgentTests.m
//  CLUUserAgentTests
//
//  Created by Sven Herzberg on 06/26/2015.
//  Copyright (c) 2015 Sven Herzberg. All rights reserved.
//

@import XCTest;

#import <CLUUserAgent/CLUUserAgent.h>

#import "CLUTestServer.h"

typedef void (^CancellationBlock) (void);
typedef void (^CompletionBlock)   (NSData* __nonnull data);
typedef CancellationBlock __nonnull (^ExecutionBlock)(NSURL* __nonnull url, CompletionBlock __nonnull);

@interface CLUUserAgentTests : XCTestCase

@property CLUUserAgent* sut;

@end

@implementation CLUUserAgentTests

@synthesize sut;

#pragma mark:- Life Cycle

// Put setup code here. This method is called before the invocation of each test method in the class.
- (void)setUp
{
    [super setUp];
}

// Put teardown code here. This method is called after the invocation of each test method in the class.
- (void)tearDown
{
    sut = nil;
    
    [super tearDown];
}

#pragma mark:- Tests

#pragma mark: +defaultOptions

- (void) testDefaultOptions
{
    // given
    CLUUserAgentOptions expected = CLUUserAgentOptionsNone;
#if TARGET_OS_MAC && !TARGET_IPHONE_SIMULATOR
    expected |= CLUUserAgentOptionsAddOSArchitecture;
    
    BOOL osxBeforeTenTen = YES;
#ifdef NSAppKitVersionNumber10_10
    osxBeforeTenTen = NSAppKitVersionNumber < NSAppKitVersionNumber10_10;
#endif
    if (osxBeforeTenTen) {
        expected |= CLUUserAgentOptionsAddDeviceModel;
    }
#endif
    
    // when
    CLUUserAgentOptions result = [CLUUserAgent defaultOptions];
    
    // then
    XCTAssertEqual(result, expected);
}

#pragma mark: -defaultUserAgent

- (void)testDefaultUserAgent
{
    // given
    sut = [[CLUUserAgent alloc] init];
    
    // when
    NSString* result = sut.stringValue;
    
    // then
    XCTAssertNotNil(result);
    XCTAssertEqualObjects(result, [self userAgentFromNSURLConnection]);
    XCTAssertEqualObjects(result, [self userAgentFromNSURLSession]);
}

#pragma mark:- Utilities

- (NSString*) userAgentFromNSURLConnection
{
    return [self userAgentByExecutingBlock:^(NSURL* url, CompletionBlock completion){
        BOOL __block cancelled = NO;
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:NSOperationQueue.mainQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (cancelled) {
                return;
            }
            
            XCTAssertNil(error);
            XCTAssertNotNil(response);
            XCTAssertNotNil(data);
            
            completion(data);
        }];
        
        return ^{
            cancelled = YES;
        };
    }];
}

- (NSString*) userAgentFromNSURLSession
{
    return [self userAgentByExecutingBlock:^(NSURL* url, CompletionBlock completion){
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        NSURLSession* session = [NSURLSession sharedSession];
        NSURLSessionTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error && [NSURLErrorDomain isEqualToString:error.domain] && error.code == NSURLErrorCancelled) {
                // The expectation has timed out/failed.
                return;
            }
            
            XCTAssertNil(error);
            XCTAssertNotNil(response);
            
            completion(data);
        }];
        [task resume];
        
        return ^() {
            [task cancel];
        };
    }];
}

- (NSString*) userAgentByExecutingBlock:(ExecutionBlock __nonnull)block
{
    CLUTestServer* server = [[CLUTestServer alloc] init];
    NSError* error;
    NSURL* testURL = [server listenAndReturnError:&error];
    XCTAssertNil(error);
    if (!testURL) {
        XCTFail(@"no URL received");
        return nil;
    }
    
    XCTestExpectation* e = [self expectationWithDescription:@"sliff"];
    
    NSString* __block nativeUserAgent;
    void (^completion) (NSData*) = ^(NSData* data) {
        XCTAssertNotNil(data);
        nativeUserAgent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [e fulfill];
    };
    void (^cancel) () = block(testURL, completion);
    
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
        XCTAssertNil(error);
        
        // FIXME: Consider -[NSError matchesDomain:code:] for these cases.
        if (error && [XCTestErrorDomain isEqualToString:error.domain] && error.code == XCTestErrorCodeTimeoutWhileWaiting) {
            cancel();
        }
    }];
    
    return nativeUserAgent;
}

@end
