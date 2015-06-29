//
//  CLUUAProduct.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 29.06.15.
//
//

#import <CLUUserAgent/CLUUserAgent.h>

@implementation CLUUAProduct

- (nonnull instancetype) initWithName:(nonnull NSString*)name version:(nullable NSString*)version weight:(NSUInteger)weight
{
    return [self initWithName:name version:version comment:nil weight:weight];
}

- (nonnull instancetype) initWithName:(nonnull NSString*)name version:(nullable NSString*)version comment:(nullable NSString*)comment weight:(NSUInteger)weight
{
    NSString* stringValue = [self escapeString:name];
    
    if (version) {
        version = [self escapeString:version];
        stringValue = [stringValue stringByAppendingFormat:@"/%@", version];
    }
    
    if (comment) {
        stringValue = [stringValue stringByAppendingFormat:@" (%@)", comment];
    }
    
    return [self initWithStringValue:stringValue weight:weight];
}

@end
