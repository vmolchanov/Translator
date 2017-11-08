#import "TranslatorAPI.h"

NSString* const TranslatorAPIAvailableLanguagesDidLoadNotification = @"TranslatorAPIAvailableLanguagesDidLoadNotification";

NSString* const TranslatorAPIAvailableLanguagesUserInfoKey = @"TranslatorAPIAvailableLanguagesUserInfoKey";

@interface TranslatorAPI ()

@property (strong, nonatomic) NSURLSession         *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;

@end

@implementation TranslatorAPI

- (void)availableLanguages {
    NSURL *url = [NSURL URLWithString:@"https://translate.yandex.net/api/v1.5/tr.json/getLangs?key=trnsl.1.1.20170704T190307Z.566133a416d294e4.7290c64a3582a3b91a5135ec64bbdd5015a37373&ui=ru"];
    
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
        // notification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[json objectForKey:@"langs"]
                                                             forKey:TranslatorAPIAvailableLanguagesUserInfoKey];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc postNotificationName:TranslatorAPIAvailableLanguagesDidLoadNotification
                          object:nil
                        userInfo:userInfo];
    };
    
    
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self.dataTask = [self.session dataTaskWithRequest:request completionHandler:completionHandler];
    [self.dataTask resume];
}


+ (TranslatorAPI *)api {
    return [[TranslatorAPI alloc] init];
}

@end
