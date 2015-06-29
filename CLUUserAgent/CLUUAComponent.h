//
//  CLUUAComponent.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 29.06.15.
//
//

#ifndef CLU_PUBLIC_CLASS
# error Only <CLUUserAgent/CLUUserAgent.h> should be included directly.
#endif

/**
 User-Agent Component Weight:
 
 The weight specifies the position inside a User-Agent. Valid values are 0 and
 1000 as well as any number between those two.
 
 @note CLUUAComponentWeightFramework is useful for developers of frameworks.
 They can use this weight to provide a reference to their framework between the
 application and transport items.
 */
typedef NS_ENUM(NSUInteger, CLUUAComponentWeight) {
    /// The weight of the device model comment (OSX before 10.10.0 only)
    CLUUAComponentWeightDeviceModel = 100,
    /// The weight of the kernel product
    CLUUAComponentWeightKernel = 300,
    /// The weight of the transport layer product (usually for CFNetwork)
    CLUUAComponentWeightTransport = 500,
    /** The weight of the framework product.
     
     @see CLUUAComponentWeight for an example.
     */
    CLUUAComponentWeightFramework = 700,
    /// The weight of the application product.
    CLUUAComponentWeightApplication = 900
};

/**
 A User-Agent component.
 
 User-Agent strings are composed of multiple components. The User-Agent
 `CERN-LineMode/2.15 libwww/2.17b3` (Example from [RFC 7231: “Hypertext Transfer
 Protocol (HTTP/1.1): Semantics and Content”; Section 5.5.3 “User-Agent”](https://tools.ietf.org/html/rfc7231#section-5.5.3))
 is composed from the product “CERN-LineMode/2.15” and the product
 “libwww/2.17b3”. The User-Agent `Googlebot/2.1 (+http://www.google.com/bot.html)`
 is composed from the product “Googlebot/2.1” and the comment
 “(+http://www.google.com/bot.html)”. These products and comments are considered
 User-Agent components.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
@interface CLUUAComponent : NSObject

/**
 Create a new User-Agent component.
 
 @param stringValue The string representation of the component.
 @param weight The weight of the component.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
- (nonnull instancetype) initWithStringValue:(nonnull NSString*)stringValue weight:(NSUInteger)weight;

/**
 The string representation of the component.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
@property (copy, readonly) NSString* __nonnull stringValue;

/**
 Escape a string to represent a token in a User-Agent.
 
 Many strings my not include spaces, escape these strings so they conform to the
 specification.
 
 @param input The input to be escaped.
 
 @availability CLUUserAgent (0.3.0 and later)
 */
- (nonnull NSString*) escapeString:(nonnull NSString*)input;

@end
