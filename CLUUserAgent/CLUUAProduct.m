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
    name = [self escapeString:name];
    
    if (!version) {
        return [self initWithStringValue:name];
    }
    
    version = [self escapeString:version];
    return [self initWithStringValue:[NSString stringWithFormat:@"%@/%@", name, version]];
}

@end
