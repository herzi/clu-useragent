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

@interface CLUUserAgent () {
    NSMutableOrderedSet* __nonnull _components;
    NSArray/*<NSSortDescriptor*>*/ * __nonnull _sortDescriptors;
}

@property CLUUserAgentOptions options;

@end

@implementation CLUUserAgent

#pragma mark: System Queries

+ (CLUUserAgentOptions)defaultOptions
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
    
    return options;
}

#pragma mark: Life Cycle Management

- (instancetype) init
{
    return [self initWithOptions:[self.class defaultOptions]];
}

- (instancetype) initWithOptions:(CLUUserAgentOptions)options
{
    self = [super init];
    
    self.options = options;
    
    return self;
}

#pragma mark: User-Agent Generator

// FIXME: Consider returning an enumerator here.
- (nonnull NSArray*) components
{
    if (!_components) {
        NSSortDescriptor* sortByWeight = [NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:NO];
        NSSortDescriptor* sortByStringValue = [NSSortDescriptor sortDescriptorWithKey:@"stringValue" ascending:YES];
        _sortDescriptors = @[sortByWeight, sortByStringValue];
        
        NSMutableOrderedSet* components = [NSMutableOrderedSet orderedSet];
        [components addObject:[self __productForApplication]];
        [components addObject:[self __productForCFNetwork]];
        [components addObject:[self __productForKernel]];
        
        if (self.options & CLUUserAgentOptionsAddDeviceModel) {
            [components addObject:[self __commentForModel]];
        }
        
        [components sortUsingDescriptors:_sortDescriptors];
        
        _components = components;
    }
    
    return [_components objectEnumerator].allObjects;
}

- (void) addComponent:(nonnull CLUUAComponent*)component
{
    if (!_components) {
        [self components];
    }
    
    // TODO: Once this becomes too slow: Calculate the index like git-bisect, then insert directly at the target position.
    [_components addObject:component];
    [_components sortUsingDescriptors:_sortDescriptors];
}

- (nonnull NSString*) stringValue
{
    NSMutableArray* strings = [NSMutableArray array];
    for (CLUUAComponent* component in self.components) {
        [strings addObject:component.stringValue];
    }
    return [strings componentsJoinedByString:@" "];
}

- (nonnull CLUUAComponent*) __commentForModel
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
    return [[CLUUAComment alloc] initWithText:model weight:CLUUAComponentWeightDeviceModel];
}

- (nonnull CLUUAComponent*) __productForApplication
{
    NSBundle* main = [NSBundle mainBundle];
    
#if TARGET_OS_MAC
    // When runnig unit tests, this won't work via the main bundle.
    if (!main.bundleIdentifier && [NSBundle bundleWithIdentifier:@"com.apple.dt.XCTest"].loaded) {
        return [[CLUUAProduct alloc] initWithName:@"xctest" version:nil comment:@"unknown version" weight:CLUUAComponentWeightApplication];
    }
#endif
    
    return [[CLUUAProduct alloc] initWithBundle:main weight:CLUUAComponentWeightApplication];
}

- (nonnull CLUUAComponent*) __productForCFNetwork
{
    NSBundle* bundle = [NSBundle bundleWithIdentifier:@"com.apple.CFNetwork"];
    return [[CLUUAProduct alloc] initWithBundle:bundle weight:CLUUAComponentWeightTransport];
}

- (nonnull CLUUAComponent*) __productForKernel
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
    
    NSString* comment = nil;
    if (self.options & CLUUserAgentOptionsAddOSArchitecture) {
        comment = [NSString stringWithCString:name.machine encoding:NSASCIIStringEncoding];
    }
    
    return [[CLUUAProduct alloc] initWithName:[NSString stringWithCString:name.sysname encoding:NSASCIIStringEncoding]
                                      version:[NSString stringWithCString:name.release encoding:NSASCIIStringEncoding]
                                      comment:comment
                                       weight:CLUUAComponentWeightKernel];
}

#pragma mark- Deprecated Methods

- (nonnull NSString*) defaultUserAgent
{
    return [self stringValue];
}

@end