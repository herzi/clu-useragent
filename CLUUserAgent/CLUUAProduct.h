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
 
 @availability CLUUserAgent (0.3.0 and later)
 */
@interface CLUUAProduct : CLUUAComponent

/**
 Initialize a product component.
 
 Using this initializer will result in a [CLUUAComponent stringValue] of “name”
 (if no version was supplied) or “name/version” (otherwise).
 
 @param name The name of the product.
 @param version The version of the product (optional).
 @param weight The weight for the product.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
- (nonnull instancetype) initWithName:(nonnull NSString*)name version:(nullable NSString*)version weight:(NSUInteger)weight;

/**
 Initialize a product component with a comment.
 
 Using this initializer will result in a [CLUUAComponent stringValue] of “name
 (comment)” (if no version was supplied) or “name/version (comment)”
 (otherwise). Using nil as a value for comment will result in a string described
 in initWithName:version:.
 
 @param name The name of the product.
 @param version The version of the product (optional).
 @param comment The comment for the product (optional).
 @param weight The weight for the product.
 
 @availability CLUUserAgent (0.3.0 and later).
 */
- (nonnull instancetype) initWithName:(nonnull NSString*)name version:(nullable NSString*)version comment:(nullable NSString*)comment weight:(NSUInteger)weight;

/**
 Initialize a product component with a bundle.
 
 Using this initializer will result in a CLUUAComponent for the specified
 bundle.
 
 @param bundle The bundle to generate the User-Agent product for.
 @param weight The weight of the product. Used to determine the position in the
 final User-Agent.
 */
- (nonnull instancetype) initWithBundle:(nonnull NSBundle*)bundle weight:(NSUInteger)weight;

@end
