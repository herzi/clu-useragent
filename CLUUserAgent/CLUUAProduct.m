//
//  CLUUAProduct.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 29.06.15.
//
//

#import <CLUUserAgent/CLUUserAgent.h>

@implementation CLUUAProduct

- (nonnull NSString*) __escape:(nonnull NSString*)input
{
    input = [input stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [input stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
}

- (nonnull instancetype) initWithName:(nonnull NSString*)name version:(nullable NSString*)version
{
    name = [self __escape:name];
    
    if (!version) {
        return [self initWithStringValue:name];
    }
    
    version = [self __escape:version];
    return [self initWithStringValue:[NSString stringWithFormat:@"%@/%@", name, version]];
}

@end
