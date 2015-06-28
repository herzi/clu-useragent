//
//  CLUMacros.h
//  CLUUserAgent
//
//  Created by Sven Herzberg on 27.06.15.
//
//

#import <Foundation/Foundation.h>

#pragma mark Deprecation Qualifiers

#define CLU_DEPRECATED __attribute__((__deprecated__))

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

#pragma mark Weak and Strong References

/* When using blocks, you should avoid retain cycles. By using these macros,
 * it's really easy to do so:
 *
 * […]
 * CLU_WEAKEN(self); // capture a weak reference to self
 * [self.worker performOpWithBlock:^(){
 *     CLU_STRENGTHEN(self); // create a strong reference named self from the
 *                           // weak reference above.
 *     if (!self) {
 *         return;           // self is gone, no need to continue
 *     }
 *
 *     // From now on, you can use `self` as a strong reference.
 *     […]
 * }];
 */

#define CLU_WEAKEN(name)     typeof(name) __weak _clu_weak_##name = name; do {} while(0)
#define CLU_STRENGTHEN(name) typeof(_clu_weak_##name) __strong name = _clu_weak_##name; do {} while(0)
