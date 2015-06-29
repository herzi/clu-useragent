//
//  CLUUAProduct.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 29.06.15.
//
//

#import <CLUUserAgent/CLUUserAgent.h>

/**
 User-Agent Product Component
 
 Product components are used to describe applications, frameworks and operating
 systems within a User-Agent.
 */
@interface CLUUAProduct : CLUUAComponent

/**
 Initialize a product component.
 
 Using this initializer will result in a [CLUUAComponent stringValue] of “name”
 (if no version was supplied) or “name/version” (otherwise).
 
 @param name The name of the product.
 @param version The version of the product (optional).
 */
- (nonnull instancetype) initWithName:(nonnull NSString*)name version:(nullable NSString*)version;

@end
