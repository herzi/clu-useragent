//
//  CLUUAComment.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 29.06.15.
//
//

#import <CLUUserAgent/CLUUserAgent.h>

/**
 User-Agent Comments:
 
 User-Agent comments can be used to include additional information.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
@interface CLUUAComment : CLUUAComponent

/**
 Create a User-Agent comment.
 
 @param text The comment text.
 @param weight The weight of the comment.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
- (nonnull instancetype) initWithText:(nonnull NSString*)text weight:(NSUInteger)weight;

@end
