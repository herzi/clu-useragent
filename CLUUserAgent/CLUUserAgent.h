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
 The class `CLUUserAgent` provides an interface to access the system's default
 User-Agent string, as being used by `NSURLSession` and `NSURLConnection`.
 */
@interface CLUUserAgent : NSObject

///----------------------------------------
/// @name Mimicking the System's User-Agent
///----------------------------------------

/**
 Returns the system's default User-Agent string.
 */
- (NSString*) defaultUserAgent;

@end
