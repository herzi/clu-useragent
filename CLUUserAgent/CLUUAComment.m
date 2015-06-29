//
//  CLUUAComment.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 29.06.15.
//
//

#import <CLUUserAgent/CLUUserAgent.h>

@implementation CLUUAComment

- (nonnull instancetype) initWithText:(nonnull NSString*)text
{
    NSString* stringValue = [NSString stringWithFormat:@"(%@)", [self escapeString:text]];
    return [self initWithStringValue:stringValue];
}

@end
