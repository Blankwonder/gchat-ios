//
//  GEChatSystemMessageCell.h
//  Grouvent
//
//  Created by Blankwonder on 1/15/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import "SPTableViewCell.h"

@interface GEChatSystemMessageCell : SPTableViewCell

@property (copy) NSString *text;

+ (CGFloat)desiredHeightWithText:(NSString *)text;

@end
