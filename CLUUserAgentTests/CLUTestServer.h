//
//  CLUTestServer.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 27.06.15.
//  Copyright (c) 2015 Sven Herzberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CLUUserAgent/CLUMacros.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLUTestServer : NSObject

- (nullable NSURL*) listenAndReturnError:(NSError*__autoreleasing*)error;

@end

NS_ASSUME_NONNULL_END
