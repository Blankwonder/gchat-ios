//
//  UIView+Freezing.h
//  koudaixiang
//
//  Created by Liu Yachen on 4/30/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Freezing)

- (void)freeze;
- (void)unfreeze;

- (BOOL)isFreezing;

@end
