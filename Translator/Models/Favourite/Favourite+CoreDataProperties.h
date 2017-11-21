#import "Favourite+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Favourite (CoreDataProperties)

+ (NSFetchRequest<Favourite *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *sourceText;
@property (nullable, nonatomic, copy) NSString *translationText;
@property (nullable, nonatomic, copy) NSString *sourceLanguageAbbr;
@property (nullable, nonatomic, copy) NSString *translationLanguageAbbr;

@end

NS_ASSUME_NONNULL_END
