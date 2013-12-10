//
//  StroageManager.h
//  koudaixiang
//
//  Created by Liu Yachen on 5/27/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GEStroageManager : NSObject

+ (GEStroageManager *)sharedInstance;

@property(readonly) NSString *logPath;
@property(readonly) NSString *cachePath;

@property(readonly) NSString *databasePath;

@end
