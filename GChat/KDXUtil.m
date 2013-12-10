//
//  KDXCUtil.c
//  koudaixiang
//
//  Created by Liu Yachen on 2/13/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "KDXUtil.h"

inline BOOL KDXUtilIsObjectNull(id object)
{
    return object == nil || object == [NSNull null];
}

inline BOOL KDXUtilIsStringValid(NSString *str)
{
    return str != nil && (id)str != [NSNull null] && ![str isEqualToString:@""];
}

NSComparisonResult _compareVersions(NSString* leftVersion, NSString* rightVersion)
{
    int i;
    
    // Break version into fields (separated by '.')
    NSMutableArray *leftFields = [[NSMutableArray alloc] initWithArray:[leftVersion componentsSeparatedByString:@"."]];
    NSMutableArray *rightFields = [[NSMutableArray alloc] initWithArray:[rightVersion componentsSeparatedByString:@"."]];
    
    // Implict ".0" in case version doesn't have the same number of '.'
    if ([leftFields count] < [rightFields count]) {
        while ([leftFields count] != [rightFields count]) {
            [leftFields addObject:@"0"];
        }
    } else if ([leftFields count] > [rightFields count]) {
        while ([leftFields count] != [rightFields count]) {
            [rightFields addObject:@"0"];
        }
    }
    
    // Do a numeric comparison on each field
    for(i = 0; i < [leftFields count]; i++) {
        NSComparisonResult result = [[leftFields objectAtIndex:i] compare:[rightFields objectAtIndex:i] options:NSNumericSearch];
        if (result != NSOrderedSame) {
            return result;
        }
    }
    
    return NSOrderedSame;
}

BOOL KDXUtilIsOSVersionHigherOrEqual(NSString* version) {
    return (_compareVersions([[UIDevice currentDevice] systemVersion], version) != NSOrderedAscending);
}

BOOL KDXUtilIs4InchScreen() {
    return [UIScreen mainScreen].bounds.size.height == 568.0;
}