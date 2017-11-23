#import <UIKit/UIKit.h>

#import "CoreDataManager.h"

@implementation CoreDataManager

#pragma mark - Getter

- (NSManagedObjectContext *)managedObjectContext {
    return self.persistentContainer.viewContext;
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Translator"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - Core Data singleton

+ (CoreDataManager *)defaultManager {
    static CoreDataManager *dataManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[CoreDataManager alloc] init];
    });
    
    return dataManager;
}

#pragma mark - Static methods

+ (UIColor *)colorFromBitwiseMask:(int32_t)bitwiseMask {
    int32_t mask = 255;
    
    int32_t red = bitwiseMask >> 16;
    int32_t green = (bitwiseMask >> 8) & mask;
    int32_t blue = bitwiseMask & mask;
    
    return [UIColor colorWithRed:(CGFloat)red / 255
                           green:(CGFloat)green / 255
                            blue:(CGFloat)blue / 255
                           alpha:1.0f];
}

+ (int32_t)bitwiseMaskByRedColor:(int32_t)red greenColor:(int32_t)green blueColor:(int32_t)blue {
    return (red << 16) | (green << 8) | blue;
}

@end
