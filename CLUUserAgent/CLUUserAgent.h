//
//  CLUUserAgent.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 06/26/2015.
//  Copyright (c) 2015 Sven Herzberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CLUUserAgent/CLUMacros.h>

/**
 Options for specifying User-Agent string features.
 */
typedef NS_OPTIONS(NSUInteger, CLUUserAgentOptions) {
    /// No special options (behave like iOS)
    CLUUserAgentOptionsNone = 0,
    /// Append the kernel CPU architecture comment (just like OSX does): `… (x86_64)`
    CLUUserAgentOptionsAddOSArchitecture = 1 << 0,
    /// Append a device model comment (just like OSX did before 10.10): `… (MacBookPro8%2C2)`
    CLUUserAgentOptionsAddDeviceModel = 1 << 1
};

/**
 The class `CLUUserAgent` provides an interface to access the system's default
 User-Agent string, as being used by `NSURLSession` and `NSURLConnection`.
 
 Using initWithOptions:, you can also create a custom User-Agent.
 */
@interface CLUUserAgent : NSObject

/** @name Creating User-Agent Objects */

/**
 Create a system default User-Agent string.
 */
- (instancetype) init;

/**
 Create a custom User-Agent string.
 
 @param options The specification of the desired User-Agent components.
 */
- (instancetype) initWithOptions:(CLUUserAgentOptions)options NS_DESIGNATED_INITIALIZER;

/// @name Getting the User-Agent configuration

/**
 Get the options used to create this User-Agent.
 */
@property (readonly) CLUUserAgentOptions options;

/** @name Mimicking the System's User-Agent */

/**
 Returns the system's default User-Agent string.
 
 @deprecated Use `-[CLUUserAgent stringValue]` instead.
 */
- (NSString*) defaultUserAgent CLU_DEPRECATED;

/** @name Accessing the User-Agent string. */

/**
 Returns User-Agent's string representation. Use this method to generate the
 `NSString*` that you want to set as your User-Agent.
 */
- (NSString*) stringValue;

@end
