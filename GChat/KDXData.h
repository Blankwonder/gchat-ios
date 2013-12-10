//
//  DataModel.h
//  koudaixiang
//
//  Created by Blankwonder on 5/28/11.
//  Copyright 2011 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^KDXDataAsyncOperationCompleteBlock)(BOOL changed);
typedef void (^KDXDataAsyncOperationBlock)(NSManagedObjectContext *context);


@interface KDXData : NSObject {
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSPersistentStore *_persistentStore;
    NSURL *_databaseURL;
    
    NSManagedObjectContext *_defaultContext;
    
    dispatch_queue_t _asyncCoreDataOperationQueue;
    dispatch_group_t _asyncCoreDataOperationGroup;
}

- (id)initWithDatabasePath:(NSURL *)pathURL
               objectModel:(NSManagedObjectModel *)managedObjectModel
    automaticResetDatabase:(BOOL)automaticResetDatabase;

- (void)reset_MainThread;

- (NSManagedObjectContext *)context_MainThread;

- (void)asyncOperation:(KDXDataAsyncOperationBlock)operationBlock
         completeBlock:(KDXDataAsyncOperationCompleteBlock)completeBlock;

@end
