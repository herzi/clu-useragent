//
//  CLUUserAgent.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 27.06.15.
//  Copyright (c) 2015 Sven Herzberg. All rights reserved.
//

#import <CLUUserAgent/CLUUserAgent.h>

@import Darwin.POSIX.sys.utsname;

// HTTP 1.1 => Notational Conventions and Generic Grammar => Basic Rules => Token / Comment Token: http://www.w3.org/Protocols/rfc2616/rfc2616-sec2.html#sec2.2
// HTTP 1.1 => Protocol Parameters => Product Token: http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.8
// HTTP 1.1 => Headers => User-Agent: http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43

@implementation CLUUserAgent

- (NSString*)defaultUserAgent
{
    NSArray* userAgent = @[[self __productForApplication],
                           [self __productForCFNetwork],
                           [self __productForOS]];
    
#if TARGET_OS_MAC
    userAgent = [userAgent arrayByAddingObject:[self __commentForOSArch]];
#endif
    
    return [userAgent componentsJoinedByString:@" "];
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