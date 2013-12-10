//
//  GEActionSheet.m
//  Grouvent
//
//  Created by Blankwonder on 11/20/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "GEActionSheet.h"

@interface GEActionSheet(){
    NSMutableArray *_buttonTitleArray;
    NSMutableArray *_buttonActionBlockArray;
    
    NSString *_cancelButtonTitle;
    void (^_cancelActionBlock)();
    
    NSString *_destructiveButtonTitle;
    void (^_destructiveActionBlock)();
    
    NSString *_title;
}
@end

static NSMutableArray *ActiveInstances = nil;

@implementation GEActionSheet

- (id)initWithTitle:(NSString *)title
  cancelButtonTitle:(NSString *)cancelButtonTitle
  cancelActionBlock:(void ( ^)())cancelActionBlock
destructiveButtonTitle:(NSString *)destructiveButtonTitle
destructiveActionBlock:(void ( ^)())destructiveActionBlock {
    self = [self init];
    if (self) {
        _buttonTitleArray = [NSMutableArray array];
        _buttonActionBlockArray = [NSMutableArray array];
        _cancelButtonTitle = cancelButtonTitle;
        _cancelActionBlock = cancelActionBlock;
        _destructiveButtonTitle = destructiveButtonTitle;
        _destructiveActionBlock = destructiveActionBlock;
        _title = title;
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title actionBlock:(void ( ^)())actionBlock {
    NSAssert(title, @"Title cannot be nil.");
    [_buttonTitleArray addObject:title];
    if (actionBlock) {
        [_buttonActionBlockArray addObject:[actionBlock copy]];
    } else {
        [_buttonActionBlockArray addObject:[NSNull null]];
    }
}

- (void)showInView:(UIView *)view {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:_title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (_destructiveButtonTitle) {
        as.destructiveButtonIndex = [as addButtonWithTitle:_destructiveButtonTitle];
    }
    for (NSString *title in _buttonTitleArray) {
        [as addButtonWithTitle:title];
    }
    if (_cancelButtonTitle) {
        as.cancelButtonIndex = [as addButtonWithTitle:_cancelButtonTitle];
    }
    [as showInView:view];
    
    if (!ActiveInstances) {
        ActiveInstances = [NSMutableArray array];
    }
    [ActiveInstances addObject:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        if (_cancelActionBlock)
            _cancelActionBlock();
    } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        if (_destructiveActionBlock)
            _destructiveActionBlock();
    } else {
        int index = buttonIndex;
        if (_destructiveButtonTitle) {
            index--;
        }
        id actionBlock = [_buttonActionBlockArray objectAtIndex:index];
        if (actionBlock && actionBlock != [NSNull null]) {
            void (^block)() = actionBlock;
            block();
        }
    }
    [ActiveInstances removeObject:self];
}

@end
