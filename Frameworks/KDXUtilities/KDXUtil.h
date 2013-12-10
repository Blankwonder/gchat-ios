//
//  KDXCUtil.h
//  koudaixiang
//
//  Created by Liu Yachen on 2/13/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KDXAssertRequireMainThread() NSAssert([NSThread isMainThread], @"This method can only be invoked on main thread!");

BOOL KDXUtilIsObjectNull(id object);
BOOL KDXUtilIsStringValid(NSString *str);

BOOL KDXUtilIsOSVersionHigherOrEqual(NSString* version);

BOOL KDXUtilIs4InchScreen();