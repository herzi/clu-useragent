//
//  CLUUserAgent.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 06/26/2015.
//  Copyright (c) 2015 Sven Herzberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CLUUserAgent/CLUMacros.h>

typedef NS_OPTIONS(NSUInteger, CLUUserAgentOptions) {
    CLUUserAgentOptionsDefault,
    CLUUserAgentOptionsAddCPUArchitecture,
    CLUUserAgentOptionsAddDeviceModel
};

/**
 The class `CLUUserAgent` provides an interface to access the system's default
 User-Agent string, as being used by `NSURLSession` and `NSURLConnection`.
 */
@interface CLUUserAgent : NSObject

///----------------------------------------
/// @name Mimicking the System's User-Agent
///----------------------------------------

/**
 Returns the system's default User-Agent string.
 
 @deprecated Use `-[CLUUserAgent stringValue]` instead.
 */
- (NSString*) defaultUserAgent;

/**
 Returns User-Agent's string representation. Use this method to generate the
 `NSString*` that you want to set as your User-Agent.
 */
- (NSString*) stringValue;

@end
