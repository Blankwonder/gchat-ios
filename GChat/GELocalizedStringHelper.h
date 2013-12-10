//
//  GELocalizedStringHelper.h
//  Grouvent
//
//  Created by Blankwonder on 11/18/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GELocalizedString(key, val) [[NSBundle mainBundle] localizedStringForKey:(key) value:(val) table:nil]
