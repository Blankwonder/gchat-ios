//
//  StroageManager.m
//  koudaixiang
//
//  Created by Liu Yachen on 5/27/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "GEStroageManager.h"

@implementation GEStroageManager

+ (GEStroageManager *)sharedInstance
{
    static dispatch_once_t pred;
    __strong static GEStroageManager *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[GEStroageManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        KDXClassLog(@"Bundle path: %@", [[NSBundle mainBundle] bundlePath]);
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryPath = [libraryPaths objectAtIndex:0];
        _cachePath = [cachePaths objectAtIndex:0];
        _logPath = [libraryPath stringByAppendingPathComponent:@"Log"];
        _databasePath = [libraryPath stringByAppendingPathComponent:@"db.sqlite"];
        
        [self createNecessaryDirectories];
    }
    return self;
}

- (void)createNecessaryDirectories {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:self.logPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
}

@end
