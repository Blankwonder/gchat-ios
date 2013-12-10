//
//  UIView+GEUIViewFrameModifyHelper.h
//  Grouvent
//
//  Created by Blankwonder on 1/4/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GEUIViewFrameModifyHelper)

- (void)setFrameOriginX:(CGFloat)value;
- (void)setFrameOriginY:(CGFloat)value;
- (void)setFrameSizeWidth:(CGFloat)value;
- (void)setFrameSizeHeight:(CGFloat)value;
- (void)setFrameOrigin:(CGPoint)value;

- (void)setFrameSizeWidthBaseOnLeft:(CGFloat)value;

@end
