//
//  UILabel+ResizeHelper.h
//  Grouvent
//
//  Created by Blankwonder on 1/12/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (ResizeHelper)

- (void)resizeBaseOnLeft;
- (void)resizeBaseOnRight;

- (void)resizeBaseOnTopWithMaxHeight:(CGFloat)height;

@end
