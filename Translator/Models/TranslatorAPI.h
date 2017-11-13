#import <Foundation/Foundation.h>

extern NSString* const TranslatorAPIAvailableLanguagesDidLoadNotification;
extern NSString* const TranslatorAPITranslationDidCompleteNotification;
extern NSString* const TranslatorAPIDetectedOtherSourceLanguageNotification;

extern NSString* const TranslatorAPIAvailableLanguagesUserInfoKey;
extern NSString* const TranslatorAPITranslationTextUserInfoKey;
extern NSString* const TranslatorAPIOtherSourceLanguageUserInfoKey;


@interface TranslatorAPI : NSObject

+ (TranslatorAPI *)api;

- (void)availableLanguages;
- (void)translateText:(NSString *)text from:(NSString *)sourceLanguage to:(NSString *)translationLanguage;

@end
