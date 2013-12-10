//
//  ChatMessage.h
//  GChat
//
//  Created by Blankwonder on 3/9/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatRoom;

@interface ChatMessage : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * sectionDate;
@property (nonatomic, retain) NSString * senderName;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) ChatRoom * chatRoom;

@end
