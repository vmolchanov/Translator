#import "Settings+CoreDataProperties.h"

@implementation Settings (CoreDataProperties)

+ (NSFetchRequest<Settings *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Settings"];
}

@dynamic themeId;
@dynamic themeColor;
@dynamic fontColor;
@dynamic isRotate;
@dynamic isTranslationByEnter;

@end
