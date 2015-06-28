//
//  CLUUserAgent.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 27.06.15.
//  Copyright (c) 2015 Sven Herzberg. All rights reserved.
//

#import <CLUUserAgent/CLUUserAgent.h>

@import Darwin.POSIX.sys.utsname; // uname()

#include <sys/sysctl.h>           // sysctlbyname()

// HTTP 1.1 => Notational Conventions and Generic Grammar => Basic Rules => Token / Comment Token: http://www.w3.org/Protocols/rfc2616/rfc2616-sec2.html#sec2.2
// HTTP 1.1 => Protocol Parameters => Product Token: http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.8
// HTTP 1.1 => Headers => User-Agent: http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43

@interface CLUUserAgent ()

@property CLUUserAgentOptions options;

@end

@implementation CLUUserAgent

#pragma mark: Life Cycle Management

- (instancetype) init
{
    NSUInteger options = CLUUserAgentOptionsNone;
    
#if TARGET_OS_MAC && !TARGET_IPHONE_SIMULATOR
    options |= CLUUserAgentOptionsAddOSArchitecture;
    
    NSProcessInfo* pi = [NSProcessInfo processInfo];
    NSOperatingSystemVersion osx = pi.operatingSystemVersion;
    if (osx.majorVersion < 10 || osx.minorVersion < 10) {
        // Starting with OSX 10.10, Apple dropped the model identifier.
        options |= CLUUserAgentOptionsAddDeviceModel;
    }
#endif

    return [self initWithOptions:options];
}

- (instancetype) initWithOptions:(CLUUserAgentOptions)options
{
    self = [super init];
    
    self.options = options;
    
    return self;
}

- (nonnull NSString*) defaultUserAgent
{
    return [self stringValue];
}

- (nonnull NSString*) stringValue
{
    NSArray* userAgent = @[[self __productForApplication],
                           [self __productForCFNetwork],
                           [self __productForOS]];
    
    if (self.options & CLUUserAgentOptionsAddOSArchitecture) {
        userAgent = [userAgent arrayByAddingObject:[self __commentForOSArch]];
    }
    
    if (self.options & CLUUserAgentOptionsAddDeviceModel) {
        userAgent = [userAgent arrayByAddingObject:[self __commentForModel]];
    }
    
    
    return [userAgent componentsJoinedByString:@" "];
}

- (nonnull NSString*) __commentForModel
{
    char modelBuffer[256];
    size_t sz = sizeof(modelBuffer);
    if (sysctlbyname("hw.model", modelBuffer, &sz, NULL, 0) < 0) {
        perror("sysctlbyname(hw.model)");
        @throw [NSException exceptionWithName:@"FIXME" reason:@"implement" userInfo:nil];
    }
    if (sz >= sizeof(modelBuffer)) {
        @throw [NSException exceptionWithName:@"FIXME" reason:@"buffer too short" userInfo:nil];
    }
    modelBuffer[sz] = 0;
    NSString* model = [NSString stringWithCString:modelBuffer encoding:NSASCIIStringEncoding];
    model = [model stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    model = [model stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    return [NSString stringWithFormat:@"(%@)", model];
}

- (nonnull NSString*) __commentForOSArch
{
    struct utsname name;
    memset(&name, 0, sizeof(name));
    if (0 > uname(&name)) {
        switch (errno) {
            case ESRCH: // No such process.
            default:
                NSAssert(NO, @"uname(3) failed: %s", strerror(errno));
                break;
        }
    }
    
    return [NSString stringWithFormat:@"(%s)", name.machine];
}

- (nonnull NSString*) __productForApplication
{
    NSBundle* main = [NSBundle mainBundle];
    
#if TARGET_OS_MAC
    // When runnig unit tests, this won't work via the main bundle.
    if (!main.bundleIdentifier && [NSBundle bundleWithIdentifier:@"com.apple.dt.XCTest"].loaded) {
        return @"xctest (unknown version)";
    }
#endif
    
    return [self __productForBundle:main];
}

- (nonnull NSString*) __productForBundle:(nonnull NSBundle*)bundle
{
    NSString* bundleName = [bundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleNameKey];
    NSString* bundleVersion = [bundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleVersionKey];
    
    return [NSString stringWithFormat:@"%@/%@", bundleName, bundleVersion];
}

- (nonnull NSString*) __productForCFNetwork
{
    return [self __productForBundle:[NSBundle bundleWithIdentifier:@"com.apple.CFNetwork"]];
}

- (nonnull NSString*) __productForOS
{
    struct utsname name;
    memset(&name, 0, sizeof(name));
    if (0 > uname(&name)) {
        switch (errno) {
            case ESRCH: // No such process.
            default:
                NSAssert(NO, @"uname(3) failed: %s", strerror(errno));
                break;
        }
    }
    
    return [NSString stringWithFormat:@"%s/%s", name.sysname, name.release];
}

@end