#import "Translation+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Translation (CoreDataProperties)

+ (NSFetchRequest<Translation *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *sourceLanguageName;
@property (nullable, nonatomic, copy) NSString *sourceLanguageAbbr;
@property (nullable, nonatomic, copy) NSString *translationLanguageName;
@property (nullable, nonatomic, copy) NSString *translationLanguageAbbr;

@end

NS_ASSUME_NONNULL_END
