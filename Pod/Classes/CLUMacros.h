//
//  CLUMacros.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 27.06.15.
//
//

/* Nullability Qualifiers were Introduced with Swift 1.2, in Xcode 6.3.
 * Xcode 6.3 was the first version to ship with the iOS 8.3 SDK. */
#if TARGET_OS_IPHONE
# ifndef __IPHONE_8_3
#  define nonnull
#  define nullable
#  define __nonnull
#  define __nullable
# endif
#elif TARGET_OS_MAC
#else
# error Unsupported Platform.
#endif