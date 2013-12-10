//
//  GEAlertView.m
//  Grouvent
//
//  Created by Blankwonder on 11/17/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "GEAlertView.h"
@interface GEAlertView(){
    NSMutableArray *_buttonTitleArray;
    NSMutableArray *_buttonActionBlockArray;
    
    NSString *_cancelButtonTitle;
    void (^_cancelBlock)();
    
    NSString *_title, *_message;
}
@end

static NSMutableArray *ActiveInstances = nil;

@implementation GEAlertView

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
        cancelBlock:(void ( ^)())cancelBlock {
    self = [self init];
    if (self) {
        _buttonTitleArray = [NSMutableArray array];
        _buttonActionBlockArray = [NSMutableArray array];
        _cancelButtonTitle = cancelButtonTitle;
        _cancelBlock = cancelBlock;
        
        _title = title;
        _message = message;
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title actionBlock:(void ( ^)())actionBlock {
    NSAssert(title, @"Title cannot be nil.");
    [_buttonTitleArray addObject:title];
    if (actionBlock) {
        [_buttonActionBlockArray addObject:actionBlock];
    } else {
        [_buttonActionBlockArray addObject:[NSNull null]];
    }
}

- (void)show {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:_title message:_message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    for (NSString *title in _buttonTitleArray) {
        [av addButtonWithTitle:title];
    }
    if (_cancelButtonTitle) {
        av.cancelButtonIndex = [av addButtonWithTitle:_cancelButtonTitle];
    }
    [av show];
    
    if (!ActiveInstances) {
        ActiveInstances = [NSMutableArray array];
    }
    [ActiveInstances addObject:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        if (_cancelBlock)
            _cancelBlock();
    } else {
        id actionBlock = [_buttonActionBlockArray objectAtIndex:buttonIndex];
        if (actionBlock && actionBlock != [NSNull null]) {
            void (^block)() = actionBlock;
            block();
        }
    }
    [ActiveInstances removeObject:self];
}

@end
