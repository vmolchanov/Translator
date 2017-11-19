#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;
- (NSManagedObjectContext *)managedObjectContext;

+ (CoreDataManager *)defaultManager;

@end
