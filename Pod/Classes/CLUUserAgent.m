//
//  CLUUserAgent.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 27.06.15.
//  Copyright (c) 2015 Sven Herzberg. All rights reserved.
//

#import <CLUUserAgent/CLUUserAgent.h>

@import Darwin.POSIX.sys.utsname;

// HTTP 1.1 => Headers => User-Agent: http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43

@implementation CLUUserAgent

- (NSString*)defaultUserAgent
{
    NSString* prefix = @"CLUUserAgent_Example/0.1.0";
    
    NSArray* userAgent = @[prefix,
                           [self __productForCFNetwork],
                           [self __productForOS]];
    return [userAgent componentsJoinedByString:@" "];
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
    int status;
    struct utsname name;
    memset(&name, 0, sizeof(name));
    status = uname(&name);
    if (status < 0) {
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