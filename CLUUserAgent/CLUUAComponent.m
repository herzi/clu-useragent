//
//  CLUUAComponent.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 29.06.15.
//
//

#import <CLUUserAgent/CLUUserAgent.h>

@interface CLUUAComponent ()

@property (copy) NSString* __nonnull stringValue;
@property NSUInteger weight;

@end

@implementation CLUUAComponent

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Calling -[CLUUAComponent init] is not permitted." userInfo:nil];
}

- (nonnull instancetype)initWithStringValue:(nonnull NSString *)stringValue weight:(NSUInteger)weight
{
    self = [super init];
    
    self.stringValue = stringValue;
    self.weight = weight;
    
    return self;
}

- (nonnull NSString*) escapeString:(nonnull NSString*)input
{
    input = [input stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [input stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
}

@end
