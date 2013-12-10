//
//  DataModel.m
//  koudaixiang
//
//  Created by Blankwonder on 5/28/11.
//  Copyright 2011 Suixing Tech. All rights reserved.
//

#import "KDXData.h"
#import "KDXUtil.h"

NSString *const kThreadCoreDataContextKey = @"ThreadCoreDataContextKey";
NSString *const kManagedObjectContextSaveCompleteBlockKey = @"ManagedObjectContextSaveCompleteBlockKey";

@implementation KDXDataContext

- (id)initWithDatabasePath:(NSURL *)pathURL
{
    self = [self init];
    if (!self) 
        return nil;
    
    KDXAssertRequireMainThread();
    
    _asyncCoreDataOperationQueue = dispatch_queue_create("com.suixingtech.kdxutilities.kdxdata.context.asyncoperationqueue", NULL);
    _asyncCoreDataOperationGroup = dispatch_group_create();
    
    _databaseURL = [pathURL copy];
            
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSError *error;
    _persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                configuration:nil
                                                                          URL:_databaseURL
                                                                      options:nil
                                                                        error:&error];
    if(!_persistentStore) {
        KDXClassLog(@"Error occered when add persistent store: %@", [error localizedDescription]);
    }
    
    _defaultContext = [[NSManagedObjectContext alloc] init];
    [_defaultContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    [_defaultContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    
    return self;
}

- (NSManagedObjectContext *)context_MainThread {
    KDXAssertRequireMainThread();
    
    dispatch_group_wait(_asyncCoreDataOperationGroup, DISPATCH_TIME_FOREVER);
    return _defaultContext;
}

- (void)mergeChangesFromOtherContext:(NSNotification *)notification {
    KDXClassLog(@"Merging context");
    
    [self performSelectorOnMainThread:@selector(mergeChangesFromOtherContext_MainThread:)
                           withObject:notification
                        waitUntilDone:NO];
}

- (void)mergeChangesFromOtherContext_MainThread:(NSNotification *)notification {
    KDXAssertRequireMainThread();
    [_defaultContext mergeChangesFromContextDidSaveNotification:notification];
    KDXClassLog(@"Merge context complete");
    KDXDataAsyncOperationCompleteBlock block = [[(NSManagedObjectContext *)notification.object userInfo] objectForKey:kManagedObjectContextSaveCompleteBlockKey];
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

- (void)asyncCoreDataOperation:(KDXDataAsyncOperationBlock)operationBlock
                 completeBlock:(KDXDataAsyncOperationCompleteBlock)completeBlock {
    dispatch_group_async(_asyncCoreDataOperationGroup, _asyncCoreDataOperationQueue ,^{
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:_persistentStoreCoordinator];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        operationBlock(context);
        
        if ([context hasChanges]) {
            KDXClassLog(@"Saving context");
            
            if (completeBlock) {
                [context.userInfo setObject:completeBlock forKey:kManagedObjectContextSaveCompleteBlockKey];
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(mergeChangesFromOtherContext:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:context];
            
            NSError *error = nil;
            if (![context save:&error]) {
                KDXClassLog(@"Error occered when save context %@", [error localizedDescription]);
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:NSManagedObjectContextDidSaveNotification
                                                          object:context];
        } else {
            KDXClassLog(@"Async CoreData operation completed, no changes.");
            if (completeBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock();
                });
            }
        }
    });

}

- (void)reset_MainThread {
    KDXAssertRequireMainThread();
    dispatch_group_wait(_asyncCoreDataOperationGroup, DISPATCH_TIME_FOREVER);
    
    NSError *error;
    [_persistentStoreCoordinator removePersistentStore:_persistentStore error:&error];
    if (error) {
        KDXClassLog(@"Error occered when remove persistent store: %@", [error localizedDescription]);
        return;
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:_databaseURL error:&error];
    if (error) {
        KDXClassLog(@"Error occered when remove database file: %@", [error localizedDescription]);
        return;
    }
    
    _persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                 configuration:nil
                                                                           URL:_databaseURL
                                                                       options:nil
                                                                         error:&error];
    if(!_persistentStore) {
        KDXClassLog(@"Error occered when add persistent store: %@", [error localizedDescription]);
    }
    
    KDXClassLog(@"Database reseted!");
}

@end
