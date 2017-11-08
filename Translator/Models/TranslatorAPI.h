#import <Foundation/Foundation.h>

extern NSString* const TranslatorAPIAvailableLanguagesDidLoadNotification;

extern NSString* const TranslatorAPIAvailableLanguagesUserInfoKey;


@interface TranslatorAPI : NSObject

+ (TranslatorAPI *)api;

- (void)availableLanguages;

@end
