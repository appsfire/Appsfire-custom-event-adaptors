/*!
 *  @header    AppsfireNativeCustomEvent.h
 *  @abstract  Appsfire Native Custom Event class.
 *  @version   1.7
 */

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPNativeCustomEvent.h"
#endif

@interface AppsfireNativeCustomEvent : MPNativeCustomEvent

@end
