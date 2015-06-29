//
//  CLUVersionTests.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 28.06.15.
//
//

#import <XCTest/XCTest.h>

#import <CLUUserAgent/CLUUserAgent.h>

@interface CLUVersionTests : XCTestCase

@end

@implementation CLUVersionTests

#pragma mark- Life Cycle

// Put setup code here. This method is called before the invocation of each test method in the class.
- (void)setUp {
    [super setUp];
}

// Put teardown code here. This method is called after the invocation of each test method in the class.
- (void)tearDown {
    [super tearDown];
}

#pragma mark- Version Handling

#pragma mark CLUUserAgentVersionString

- (void) testVersionStringMatchesInfoPlist
{
    // given
    NSBundle* bundle = [NSBundle bundleWithIdentifier:@"com.github.herzi.CLUUserAgent"];
    NSString* bundleVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    // when
    NSString* result = [NSString stringWithCString:CLUUserAgentVersionString encoding:NSUTF8StringEncoding];
    
    // then
    XCTAssertEqualObjects(result, bundleVersion);
}

#pragma mark CLUUserAgentVersionMajor, CLUUserAgentVersionMinor, CLUUserAgentVersionMicro

- (void) testVersionStringMatchesComponents
{
    // given
    NSString* versionString = [NSString stringWithCString:CLUUserAgentVersionString encoding:NSUTF8StringEncoding];
    
    // when
    NSString* result = [NSString stringWithFormat:@"%u.%u.%u",
                        CLUUserAgentVersionMajor,
                        CLUUserAgentVersionMinor,
                        CLUUserAgentVersionMicro];
    
    // then
    XCTAssertEqualObjects(result, versionString);
}

#pragma mark CLUUserAgentVersion

- (void) testVersionCodeMatchesComponents
{
    // given
    int code = CLUUserAgentVersionMajor * 100;
    code += CLUUserAgentVersionMinor;
    code *= 100;
    code += CLUUserAgentVersionMicro;
    
    // when
    int result = CLUUserAgentVersion;
    
    // then
    XCTAssertEqual(result, code);
}

@end
