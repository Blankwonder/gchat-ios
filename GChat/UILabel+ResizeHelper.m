//
//  UILabel+ResizeHelper.m
//  Grouvent
//
//  Created by Blankwonder on 1/12/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import "UILabel+ResizeHelper.h"
#import "UIView+GEUIViewFrameModifyHelper.h"

@implementation UILabel (ResizeHelper)

- (void)resizeBaseOnLeft {
    CGSize size = [self.text sizeWithFont:self.font];
    [self setFrameSizeWidth:size.width];
}

- (void)resizeBaseOnRight {
    CGSize size = [self.text sizeWithFont:self.font];
    CGRect frame = self.frame;
    CGFloat delta = frame.size.width - size.width;
    frame.size.width = size.width;
    frame.origin.x += delta;
    self.frame = frame;
}
- (void)resizeBaseOnTopWithMaxHeight:(CGFloat)height {
    CGSize size = [self.text sizeWithFont:self.font
                        constrainedToSize:CGSizeMake(self.bounds.size.width, height)
                            lineBreakMode:self.lineBreakMode];
    [self setFrameSizeHeight:size.height];
}

@end
