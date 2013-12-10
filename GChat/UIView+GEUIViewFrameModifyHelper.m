//
//  UIView+GEUIViewFrameModifyHelper.m
//  Grouvent
//
//  Created by Blankwonder on 1/4/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import "UIView+GEUIViewFrameModifyHelper.h"

@implementation UIView (GEUIViewFrameModifyHelper)

- (void)setFrameOriginX:(CGFloat)value {
    CGRect frame = self.frame;
    frame.origin.x = value;
    self.frame = frame;
}
- (void)setFrameOriginY:(CGFloat)value {
    CGRect frame = self.frame;
    frame.origin.y = value;
    self.frame = frame;
}
- (void)setFrameSizeWidth:(CGFloat)value {
    CGRect frame = self.frame;
    frame.size.width = value;
    self.frame = frame;
}
- (void)setFrameSizeHeight:(CGFloat)value {
    CGRect frame = self.frame;
    frame.size.height = value;
    self.frame = frame;
}

- (void)setFrameOrigin:(CGPoint)value {
    CGRect frame = self.frame;
    frame.origin = value;
    self.frame = frame;
}
- (void)setFrameSizeWidthBaseOnLeft:(CGFloat)value {
    CGRect frame = self.frame;
    frame.origin.x -= value - frame.size.width;
    frame.size.width = value;
    self.frame = frame;
}

@end
