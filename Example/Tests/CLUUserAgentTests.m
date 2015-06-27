//
//  CLUUserAgentTests.m
//  CLUUserAgentTests
//
//  Created by Sven Herzberg on 06/26/2015.
//  Copyright (c) 2015 Sven Herzberg. All rights reserved.
//

@import XCTest;
@import CLUUserAgent;

@interface CLUUserAgentTests : XCTestCase

@end

@implementation CLUUserAgentTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    // given
    CLUUserAgent* sut = [[CLUUserAgent alloc] init];
    
    // when
    NSString* result = [sut defaultUserAgent];
    
    // then
    XCTAssertEqualObjects(result, @"CLUUserAgent_Example/0.1.0 CFNetwork/711.3.18 Darwin/14.3.0");
}

@end
