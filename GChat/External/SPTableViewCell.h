//
//  SPTableViewCell.h
//  SimplierTouch
//
//  Created by Chongyu Zhu on 11/10/11.
//  Copyright (c) 2011 Chongyu Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *kSPTableViewCellIdentifier;

@interface SPTableViewCell : UITableViewCell {
@private
    UIView *_cellContentView;
}

@property (weak, nonatomic, readonly) UIView *cellContentView;
@property (nonatomic, readonly) CGRect cellContentBounds;

- (void)drawCellContentRect:(CGRect)rect;

@end
