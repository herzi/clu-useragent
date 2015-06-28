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
 
 - `CLUUserAgentOptionsNone`: No special options (behave like iOS)
 - `CLUUserAgentOptionsAddOSArchitecture`: Append the kernel CPU architecture comment (just like OSX does): `… (x86_64)`
 - `CLUUserAgentOptionsAddDeviceModel`: Append a device model comment (just like OSX did before 10.10): `… (MacBookPro8%2C2)`
 */
typedef NS_OPTIONS(NSUInteger, CLUUserAgentOptions) {
    CLUUserAgentOptionsNone = 0,
    CLUUserAgentOptionsAddOSArchitecture = 1 << 0,
    CLUUserAgentOptionsAddDeviceModel = 1 << 1
};

/**
 The class `CLUUserAgent` provides an interface to access the system's default
 User-Agent string, as being used by `NSURLSession` and `NSURLConnection`.
 
 Currently, this class only provides an interface to access the system's default
 User-Agent. In the future, it will also provide a way to set up and customize
 your own User-Agent strings.
 */
@interface CLUUserAgent : NSObject

/** @name Mimicking the System's User-Agent */

/**
 Returns the system's default User-Agent string.
 
 @deprecated Use `-[CLUUserAgent stringValue]` instead.
 */
- (NSString*) defaultUserAgent;

/** @name Accessing the User-Agent string. */

/**
 Returns User-Agent's string representation. Use this method to generate the
 `NSString*` that you want to set as your User-Agent.
 */
- (NSString*) stringValue;

@end
