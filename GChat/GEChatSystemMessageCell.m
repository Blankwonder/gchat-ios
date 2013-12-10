//
//  GEChatSystemMessageCell.m
//  Grouvent
//
//  Created by Blankwonder on 1/15/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import "GEChatSystemMessageCell.h"

static UIImage *BackgroundImage;

@implementation GEChatSystemMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!BackgroundImage) {
            BackgroundImage = [[UIImage imageResourceNamed:@"chat_system_message"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
        }
    }
    return self;
}


- (void)drawCellContentRect:(CGRect)rect {
    CGSize textSize = [GEChatSystemMessageCell sizeWithText:self.text];

    [BackgroundImage drawInRect:CGRectMake((320 - textSize.width) / 2 - 10, 5, textSize.width + 20, textSize.height + 10)];

    [[UIColor whiteColor] set];
    [self.text drawInRect:CGRectMake((320 - textSize.width) / 2, 10, textSize.width, textSize.height) withFont:[UIFont systemFontOfSize:15]];
}

+ (CGSize)sizeWithText:(NSString *)text {
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:15]
                       constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)];
    return textSize;
}

+ (CGFloat)desiredHeightWithText:(NSString *)text {
    CGSize textSize = [GEChatSystemMessageCell sizeWithText:text];
    return textSize.height + 20;
}

@end
