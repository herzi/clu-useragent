//
//  CLUUAProduct.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 29.06.15.
//
//

#import <CLUUserAgent/CLUUserAgent.h>

@implementation CLUUAProduct

- (nonnull instancetype) initWithName:(nonnull NSString*)name version:(nullable NSString*)version
{
    return [self initWithName:name version:version comment:nil];
}

- (nonnull instancetype) initWithName:(nonnull NSString*)name version:(nullable NSString*)version comment:(nullable NSString*)comment
{
    NSString* stringValue = [self escapeString:name];
    
    if (version) {
        version = [self escapeString:version];
        stringValue = [stringValue stringByAppendingFormat:@"/%@", version];
    }
    
    if (comment) {
        stringValue = [stringValue stringByAppendingFormat:@" (%@)", comment];
    }
    
    return [self initWithStringValue:stringValue];
}

@end
