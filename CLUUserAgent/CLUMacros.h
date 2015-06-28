//
//  CLUMacros.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 27.06.15.
//
//

#import <Foundation/Foundation.h>

#pragma mark Nullability Qualifiers

/* Nullability Qualifiers were Introduced with Swift 1.2, in Xcode 6.3.
 *
 * Xcode 6.3 was the first version to ship with the iOS 8.3 SDK and the OSX
 * 10.10.3 SDK.
 */

#if !__has_feature(nullability)
# ifdef __OBJC__
#  define NS_ASSUME_NONNULL_BEGIN
#  define NS_ASSUME_NONNULL_END
#  define nullable
#  define nonnull
#  define null_unspecified
#  define null_resettable
# endif
# define __nullable
# define __nonnull
# define __null_unspecified
#endif
