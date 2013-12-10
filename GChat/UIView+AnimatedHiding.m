//
//  UIView+UIView_AnimateHiding.m
//  koudaixiang
//
//  Created by Liu Yachen on 11/15/11.
//  Copyright (c) 2011 Suixing Tech. All rights reserved.
//

#import "UIView+AnimatedHiding.h"

@implementation UIView (AnimatedHiding)

- (void)setHidden:(BOOL)hidden animationDuration:(NSTimeInterval)duration {
    if (self.hidden != hidden) {
        if (hidden) {
            __block UIView *selfInBlock = self;
            CGFloat originAlpha = self.alpha;
            [UIView animateWithDuration:duration 
                                  delay:0 
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{ 
                                 self.alpha = 0;
                             } 
                             completion:^(BOOL finished){
                                 selfInBlock.hidden = YES;
                                 selfInBlock.alpha = originAlpha;
                             }];
            
        } else {
            CGFloat originAlpha = self.alpha;
            self.hidden = NO;
            self.alpha = 0;
            [UIView animateWithDuration:duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ 
                                 self.alpha = originAlpha;
                             } 
                             completion:NULL];
        }
    }
}

@end
