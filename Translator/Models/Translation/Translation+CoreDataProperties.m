#import "Translation+CoreDataProperties.h"

@implementation Translation (CoreDataProperties)

+ (NSFetchRequest<Translation *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Translation"];
}

@dynamic sourceLanguageName;
@dynamic sourceLanguageAbbr;
@dynamic translationLanguageName;
@dynamic translationLanguageAbbr;

@end
