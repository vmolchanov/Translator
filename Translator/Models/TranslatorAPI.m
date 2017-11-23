#import "TranslatorAPI.h"

NSString* const TranslatorAPIAvailableLanguagesDidLoadNotification = @"TranslatorAPIAvailableLanguagesDidLoadNotification";
NSString* const TranslatorAPITranslationDidCompleteNotification = @"TranslatorAPITranslationDidCompleteNotification";
NSString* const TranslatorAPIDetectedOtherSourceLanguageNotification = @"TranslatorAPIDetectedOtherSourceLanguageNotification";

NSString* const TranslatorAPIAvailableLanguagesUserInfoKey = @"TranslatorAPIAvailableLanguagesUserInfoKey";
NSString* const TranslatorAPITranslationTextUserInfoKey = @"TranslatorAPITranslationTextUserInfoKey";
NSString* const TranslatorAPIOtherSourceLanguageUserInfoKey = @"TranslatorAPIOtherSourceLanguageUserInfoKey";

@interface TranslatorAPI ()

@property (strong, nonatomic) NSURLSession         *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic, readonly) NSString   *key;

@end

@implementation TranslatorAPI

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self->_key = @"trnsl.1.1.20170704T190307Z.566133a416d294e4.7290c64a3582a3b91a5135ec64bbdd5015a37373";
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    
    return self;
}

#pragma mark - API

- (void)availableLanguages {
    NSString *ui = @"ru";
    NSString *urlString = [NSString stringWithFormat:
                           @"https://translate.yandex.net/api/v1.5/tr.json/getLangs?key=%@&ui=%@",
                           self.key,
                           ui];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 10;
    
    void (^completionHandler)(NSData*, NSURLResponse*, NSError*) = ^(NSData * _Nullable data,
                                                                     NSURLResponse * _Nullable response,
                                                                     NSError * _Nullable error) {
        if (error) {
            // processing error
        }
        
        id json = [NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingMutableContainers
                                                    error:nil];
        // Notification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[json objectForKey:@"langs"]
                                                             forKey:TranslatorAPIAvailableLanguagesUserInfoKey];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc postNotificationName:TranslatorAPIAvailableLanguagesDidLoadNotification
                          object:nil
                        userInfo:userInfo];
    };
    
    self.dataTask = [self.session dataTaskWithRequest:request completionHandler:completionHandler];
    [self.dataTask resume];
}

- (void)translateText:(NSString *)text from:(NSString *)sourceLanguage to:(NSString *)translationLanguage {
    text = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    __block NSString *lang = [NSString stringWithFormat:@"%@-%@", sourceLanguage, translationLanguage];
    NSString *options = @"1";
    
    __block NSString *urlString = [NSString stringWithFormat:
                                   @"https://translate.yandex.net/api/v1.5/tr.json/translate?key=%@&text=%@&lang=%@&options=%@",
                                   self.key,
                                   text,
                                   lang,
                                   options];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 10;
    
    __weak typeof(self) weakSelf = self;
    
    void (^completionHandler)(NSData*, NSURLResponse*, NSError*) = ^(NSData * _Nullable data,
                                                                     NSURLResponse * _Nullable response,
                                                                     NSError * _Nullable error) {
        if (error) {
            // processing error
        }
        
        id json = [NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingMutableContainers
                                                    error:nil];
        
        if (![[[json objectForKey:@"detected"] objectForKey:@"lang"] isEqualToString:sourceLanguage]) {
            NSString *detectedLang = [[json objectForKey:@"detected"] objectForKey:@"lang"];
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            
            [nc postNotificationName:TranslatorAPIDetectedOtherSourceLanguageNotification
                              object:nil
                            userInfo:[NSDictionary dictionaryWithObject:detectedLang
                                                                 forKey:TranslatorAPIOtherSourceLanguageUserInfoKey]];
            
            [weakSelf translateText:text from:detectedLang to:translationLanguage];
            
            return;
        }
        
        // Notification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[json objectForKey:@"text"]
                                                             forKey:TranslatorAPITranslationTextUserInfoKey];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc postNotificationName:TranslatorAPITranslationDidCompleteNotification
                          object:nil
                        userInfo:userInfo];
    };
    
    self.dataTask = [self.session dataTaskWithRequest:request completionHandler:completionHandler];
    [self.dataTask resume];
}

#pragma mark - Convenience constructor

+ (TranslatorAPI *)api {
    return [[TranslatorAPI alloc] init];
}

@end
