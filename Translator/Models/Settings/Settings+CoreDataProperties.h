#import "Settings+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Settings (CoreDataProperties)

+ (NSFetchRequest<Settings *> *)fetchRequest;

@property (nonatomic) int16_t themeColor;
@property (nonatomic) int16_t fontColor;
@property (nonatomic) BOOL isRotate;
@property (nonatomic) BOOL isTranslationByEnter;

@end

NS_ASSUME_NONNULL_END
