//
//  UIViewController+InitHelper.m
//  Grouvent
//
//  Created by Blankwonder on 11/12/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "UIViewController+InitHelper.h"

@implementation UIViewController (InitHelper)

- (id)initWithDefaultNibName {
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

@end
