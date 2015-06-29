//
//  CLUUserAgent.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 06/26/2015.
//  Copyright (c) 2015 Sven Herzberg. All rights reserved.
//

/* In this header, you should import all the public headers of your framework
 * using statements like #import <CLUUserAgent/PublicHeader.h> */

#import <Foundation/Foundation.h>
#import <CLUUserAgent/CLUUAComponent.h>
#import <CLUUserAgent/CLUMacros.h>
#import <CLUUserAgent/CLUVersion.h>

/**
 Options for specifying User-Agent string features.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
typedef NS_OPTIONS(NSUInteger, CLUUserAgentOptions) {
    /**
     No special options (behave like iOS)
     
     @availability CLUUserAgent (0.3.0 and later)
     */
    CLUUserAgentOptionsNone = 0,
    /**
     Append the kernel CPU architecture comment (just like OSX does): `… (x86_64)`
     
     @availability CLUUserAgent (0.3.0 and later)
     */
    CLUUserAgentOptionsAddOSArchitecture = 1 << 0,
    /**
     Append a device model comment (just like OSX did before 10.10): `… (MacBookPro8%2C2)`
     
     @availability CLUUserAgent (0.3.0 and later)
     */
    CLUUserAgentOptionsAddDeviceModel = 1 << 1
};

/**
 The class `CLUUserAgent` provides an interface to access the system's default
 User-Agent string, as being used by `NSURLSession` and `NSURLConnection`.
 
 Using initWithOptions:, you can also create a custom User-Agent.
 
 @availability CLUUserAgent (0.1.0 and later)
 */
@interface CLUUserAgent : NSObject

/// @name Query the System's User-Agent

/**
 Query the preferred User-Agent options for the current system.

 This method will return the CLUUserAgentOptions required to create a User-Agent
 that looks just like the default one.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
+ (CLUUserAgentOptions) defaultOptions;

/** @name Creating User-Agent Objects */

/**
 Create a system default User-Agent string.
 
 @availability CLUUserAgent (0.1.0 and later)
 */
- (nonnull instancetype) init;

/**
 Create a custom User-Agent string.
 
 @param options The specification of the desired User-Agent components.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
- (nonnull instancetype) initWithOptions:(CLUUserAgentOptions)options NS_DESIGNATED_INITIALIZER;

/// @name Getting the User-Agent configuration

/**
 Get the components constituting the User-Agent.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
@property (copy, readonly) NSArray/*<CLUUAComponent>*/ *__nonnull components;

/**
 Get the options used to create this User-Agent.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
@property (readonly) CLUUserAgentOptions options;

/** @name Accessing the User-Agent string. */

/**
 Returns User-Agent's string representation. Use this method to generate the
 `NSString*` that you want to set as your User-Agent.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
@property (copy, readonly) NSString* __nonnull stringValue;

/// @name Deprecated Methods

/**
 Returns the system's default User-Agent string.
 
 @availability CLUUserAgent (0.1.0 until 0.3.x)
 @deprecated Use property stringValue instead.
 @see stringValue
 */
- (nonnull NSString*) defaultUserAgent CLU_DEPRECATED;

@end
