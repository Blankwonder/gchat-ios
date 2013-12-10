//
//  GEChatMessageCell.m
//  Grouvent
//
//  Created by Blankwonder on 11/27/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "GEChatMessageCell.h"

static UIImage *GEChatMessageCellChatBubbleImageLeft;
static UIImage *GEChatMessageCellChatBubbleImageRight;

@implementation GEChatMessageCell

- (id)initWithChatMessageStyle:(GEChatMessageCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _chatMessageStyle = style;
        
        if (!GEChatMessageCellChatBubbleImageLeft) {
            GEChatMessageCellChatBubbleImageLeft = [[UIImage imageResourceNamed:@"chat_bubble"] stretchableImageWithLeftCapWidth:26 topCapHeight:17];
        }
        if (!GEChatMessageCellChatBubbleImageRight) {
            GEChatMessageCellChatBubbleImageRight = [[UIImage imageResourceNamed:@"chat_bubble_right"] stretchableImageWithLeftCapWidth:18 topCapHeight:17];
        }
    }
    return self;
}

- (void)setShowActivityIndicator:(BOOL)showActivityIndicator {
    if (showActivityIndicator) {
        if (!_activityIndicatorView) {
            _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [self.contentView addSubview:_activityIndicatorView];
        }
//        [_activityIndicatorView startAnimating];
        _activityIndicatorView.hidden = YES;
    } else {
        _activityIndicatorView.hidden = YES;
    }
}

- (void)drawCellContentRect:(CGRect)rect {
    CGSize textSize = [GEChatMessageCell sizeWithText:_text];

    if (_chatMessageStyle == GEChatMessageCellStyleLeft) {
        [GEChatMessageCellChatBubbleImageLeft drawInRect:CGRectMake(5, 8, textSize.width + 30, textSize.height + 20)];

        [[UIColor colorWithRed:0.384314 green:0.384314 blue:0.384314 alpha:1.0] set];
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 1), 0, [UIColor colorWithWhite:1 alpha:0.6].CGColor);
        [_text drawInRect:CGRectMake(23, 16, textSize.width, textSize.height)
                 withFont:[UIFont systemFontOfSize:15]
            lineBreakMode:NSLineBreakByWordWrapping];
    } else {
        [GEChatMessageCellChatBubbleImageRight drawInRect:CGRectMake(320 - textSize.width - 32, 8, textSize.width + 30, textSize.height + 20)];

        [[UIColor colorWithRed:0.301961 green:0.290196 blue:0.290196 alpha:1.0] set];
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(0, 1), 0, [UIColor colorWithWhite:1 alpha:0.45].CGColor);
        [_text drawInRect:CGRectMake(320 - 20 - textSize.width, 16, textSize.width, textSize.height)
                 withFont:[UIFont systemFontOfSize:15]
            lineBreakMode:NSLineBreakByWordWrapping];
    }

    if (_sender) {
        [GEUIColorWithRGB(119.0, 119.0, 119.0) set];
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext()
                                    , CGSizeMake(0, 1), 0, [UIColor colorWithWhite:1 alpha:1].CGColor);
        if (_chatMessageStyle == GEChatMessageCellStyleLeft) {
            [_sender drawInRect:CGRectMake(10, self.bounds.size.height - 13, 320, 15)
                       withFont:[UIFont boldSystemFontOfSize:10]
                  lineBreakMode:NSLineBreakByTruncatingTail
                      alignment:NSTextAlignmentLeft];
        } else {
            [_sender drawInRect:CGRectMake(0, self.bounds.size.height - 13, 310, 15)
                       withFont:[UIFont boldSystemFontOfSize:10]
                  lineBreakMode:NSLineBreakByTruncatingTail
                      alignment:NSTextAlignmentRight];
        }
    }
}

+ (CGSize)sizeWithText:(NSString *)text {
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:15]
                       constrainedToSize:CGSizeMake(285, CGFLOAT_MAX)];
    if (textSize.width < 12) {
        textSize.width = 12;
    }

    if (textSize.height < 15) {
        textSize.height = 15;
    }
    return textSize;
}

+ (CGFloat)desiredHeightWithText:(NSString *)text{
    CGSize textSize = [GEChatMessageCell sizeWithText:text];
    return textSize.height + 38;
}

@end
