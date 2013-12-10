//
//  SPTableViewCell.m
//  SimplierTouch
//
//  Created by Chongyu Zhu on 11/10/11.
//  Copyright (c) 2011 Chongyu Zhu. All rights reserved.
//

#import "SPTableViewCell.h"

NSString *kSPTableViewCellIdentifier = @"SPTableViewCellIdentifier";

@interface SPTableViewCellView : UIView {
@private
    BOOL _highlighted;
}
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@end

@implementation SPTableViewCellView
@synthesize highlighted = _highlighted;

- (void)drawRect:(CGRect)rect
{
    UIView *tableViewCell = [[self superview] superview];
    if (tableViewCell != nil && [tableViewCell isKindOfClass:[SPTableViewCell class]]) {
        [(SPTableViewCell *)tableViewCell drawCellContentRect:rect];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (_highlighted != highlighted) {
        _highlighted = highlighted;
        [self setNeedsDisplay];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}
@end

@implementation SPTableViewCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellContentView = [[SPTableViewCellView alloc] initWithFrame:self.contentView.bounds];
        _cellContentView.opaque = NO;
        _cellContentView.backgroundColor = [UIColor clearColor];
        _cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _cellContentView.contentMode = UIViewContentModeLeft;
        [[self contentView] addSubview:_cellContentView];
    }
    
    return self;
}

#pragma mark - Memory management


#pragma mark - Inheritance

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [_cellContentView setNeedsDisplay];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Cell content view

- (UIView *)cellContentView
{
    return _cellContentView;
}

- (CGRect)cellContentBounds
{
    return [_cellContentView bounds];
}

- (void)drawCellContentRect:(CGRect)rect
{
}

@end
