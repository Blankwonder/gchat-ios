//
//  DataModel.m
//  koudaixiang
//
//  Created by Blankwonder on 5/28/11.
//  Copyright 2011 Suixing Tech. All rights reserved.
//

#import "KDXData.h"

NSString *const kManagedObjectContextSaveCompleteBlockKey = @"ManagedObjectContextSaveCompleteBlockKey";

@implementation KDXData

- (id)initWithDatabasePath:(NSURL *)pathURL
               objectModel:(NSManagedObjectModel *)managedObjectModel
    automaticResetDatabase:(BOOL)automaticResetDatabase
{
    KDXAssertRequireMainThread();
    
    self = [self init];
    if (!self) 
        return nil;

    if (!managedObjectModel) {
        managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    
    _databaseURL = [pathURL copy];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

    NSError *error = [self addPersistentStore];
    if (error || !_persistentStore) {
        if (automaticResetDatabase) {
            KDXClassLog(@"Trying to reset database");
            [[NSFileManager defaultManager] removeItemAtURL:_databaseURL error:nil];
            NSError *error = [self addPersistentStore];
            if (error || !_persistentStore) {
                return nil;
            }
        } else {
            return nil;
        }
    }

    _defaultContext = [[NSManagedObjectContext alloc] init];
    [_defaultContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    [_defaultContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];

    _asyncCoreDataOperationQueue = dispatch_queue_create("com.suixingtech.kdxutilities.kdxdata.context.asyncoperationqueue", NULL);
    _asyncCoreDataOperationGroup = dispatch_group_create();

    return self;
}

- (NSError *)addPersistentStore {
    NSError *error;
    _persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                 configuration:nil
                                                                           URL:_databaseURL
                                                                       options:nil
                                                                         error:&error];
    if (error || !_persistentStore) {
        KDXClassLog(@"Error occered when add persistent store: %@", [error localizedDescription]);
    }

    return error;
}

- (void)dealloc {
    dispatch_release(_asyncCoreDataOperationQueue);
    dispatch_release(_asyncCoreDataOperationGroup);
}

- (NSManagedObjectContext *)context_MainThread {
    KDXAssertRequireMainThread();
    
    dispatch_group_wait(_asyncCoreDataOperationGroup, DISPATCH_TIME_FOREVER);
    return _defaultContext;
}

- (void)mergeChangesFromOtherContext:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(mergeChangesFromOtherContext_MainThread:)
                           withObject:notification
                        waitUntilDone:NO];
}

- (void)mergeChangesFromOtherContext_MainThread:(NSNotification *)notification {
    KDXAssertRequireMainThread();
    [_defaultContext mergeChangesFromContextDidSaveNotification:notification];
    KDXDataAsyncOperationCompleteBlock block = [[(NSManagedObjectContext *)notification.object userInfo] objectForKey:kManagedObjectContextSaveCompleteBlockKey];
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(YES);
        });
    }
}

- (void)asyncOperation:(KDXDataAsyncOperationBlock)operationBlock
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
            if (completeBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(NO);
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
        KDXClassLog(@"Error occered when reset database: %@", error.localizedDescription);
        return;
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:_databaseURL error:&error];
    if (error) {
        KDXClassLog(@"Error occered when reset database: %@", error.localizedDescription);
        return;
    }

    [self addPersistentStore];

    KDXClassLog(@"Database reseted!");
}

@end
