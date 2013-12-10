//
//  KDXEasyTouchButton.m
//  koudaixiang
//
//  Created by Liu Yachen on 6/24/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "KDXEasyTouchButton.h"

@interface KDXEasyTouchButtonDarkView : UIView
@property BOOL highlighted;
@end
@implementation KDXEasyTouchButtonDarkView

- (void)drawRect:(CGRect)rect {
    if (self.highlighted) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:0.3].CGColor);
        CGContextFillRect(context, rect);
    }
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self.superview;
}

@end

@implementation KDXEasyTouchButton {
    BOOL _adjustAllRectWhenHighlighted;
    KDXEasyTouchButtonDarkView *_darkView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.bounds, point)) {
        return YES;
    }else {
        return NO;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    _darkView.highlighted = highlighted;
    [_darkView setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _darkView.frame = self.bounds;
}

- (void)setAdjustAllRectWhenHighlighted:(BOOL)adjustAllRectWhenHighlighted {
    _adjustAllRectWhenHighlighted = adjustAllRectWhenHighlighted;
    self.adjustsImageWhenHighlighted = NO;
    if (adjustAllRectWhenHighlighted) {
        if (!_darkView) {
            _darkView = [[KDXEasyTouchButtonDarkView alloc] initWithFrame:self.bounds];
            _darkView.backgroundColor = [UIColor clearColor];
            _darkView.userInteractionEnabled = YES;
            [self addSubview:_darkView];
        }
    } else {
        if (_darkView) {
            [_darkView removeFromSuperview];
            _darkView = nil;
        }
    }
}

- (BOOL)adjustAllRectWhenHighlighted { return _adjustAllRectWhenHighlighted; }

@end
