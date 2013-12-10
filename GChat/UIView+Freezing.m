//
//  UIView+Freezing.m
//  koudaixiang
//
//  Created by Liu Yachen on 4/30/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "UIView+Freezing.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

const NSInteger FreezingImageViewTag = -100001;
static char HiddenStatusKey;

@implementation UIView (Freezing)

- (void)freeze {
    if ([self isFreezing])
        return;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSMutableArray *hiddenStatus = [NSMutableArray arrayWithCapacity:self.subviews.count];
    for (int i = 0 ; i < self.subviews.count ; i++) {
        UIView *subview = [self.subviews objectAtIndex:i];
        [hiddenStatus addObject:[NSNumber numberWithBool:subview.hidden]];
        subview.hidden = YES;
    }
    
    objc_setAssociatedObject(self,
                             &HiddenStatusKey,
                             hiddenStatus,
                             OBJC_ASSOCIATION_RETAIN);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:viewImage];
    imageView.opaque = YES;
    imageView.tag = FreezingImageViewTag;
    [self addSubview:imageView];
}

- (void)unfreeze {
    NSMutableArray *hiddenStatus = objc_getAssociatedObject(self, &HiddenStatusKey);
    if (hiddenStatus == nil) {
        return;
    }
    
    UIImageView *imageView = (UIImageView *)[self viewWithTag:FreezingImageViewTag];
    [imageView removeFromSuperview];
    
    for (int i = 0 ; i < self.subviews.count ; i++) {
        UIView *subview = [self.subviews objectAtIndex:i];
        subview.hidden = [[hiddenStatus objectAtIndex:i] boolValue];
    }
    
    objc_setAssociatedObject(self,
                             &HiddenStatusKey,
                             nil,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isFreezing {
    NSMutableArray *hiddenStatus = objc_getAssociatedObject(self, &HiddenStatusKey);
    return hiddenStatus != nil;
}

@end
