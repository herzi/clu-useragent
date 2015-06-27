//
//  CLUTestServer.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 27.06.15.
//  Copyright (c) 2015 Sven Herzberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CLUUserAgent/CLUMacros.h>

@interface CLUTestServer : NSObject

- (nullable NSURL*) listenAndReturnError:(NSError*__autoreleasing __nullable *__nonnull)error;

@end
