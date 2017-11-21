#import "Favourite+CoreDataProperties.h"

@implementation Favourite (CoreDataProperties)

+ (NSFetchRequest<Favourite *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Favourite"];
}

@dynamic sourceText;
@dynamic translationText;
@dynamic sourceLanguageAbbr;
@dynamic translationLanguageAbbr;

@end
