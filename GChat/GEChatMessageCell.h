//
//  GEChatMessageCell.h
//  Grouvent
//
//  Created by Blankwonder on 11/27/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "SPTableViewCell.h"

typedef enum {
    GEChatMessageCellStyleLeft,
    GEChatMessageCellStyleRight
} GEChatMessageCellStyle;

@interface GEChatMessageCell : SPTableViewCell {
    UIActivityIndicatorView *_activityIndicatorView;
}

- (id)initWithChatMessageStyle:(GEChatMessageCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *sender;
@property (nonatomic) GEChatMessageCellStyle chatMessageStyle;

- (void)setShowActivityIndicator:(BOOL)showActivityIndicator;
+ (CGFloat)desiredHeightWithText:(NSString *)text;

@end
