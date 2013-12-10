//
//  ChatRoom.h
//  GChat
//
//  Created by Blankwonder on 3/11/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatMessage;

@interface ChatRoom : NSManagedObject

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * lastReadMessageID;
@property (nonatomic, retain) NSString * selfNickname;
@property (nonatomic, retain) NSString * serverAddress;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * joinSignature;
@property (nonatomic, retain) NSString * shortlink;
@property (nonatomic, retain) NSDate * joinDate;
@property (nonatomic, retain) NSSet *messages;
@end

@interface ChatRoom (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(ChatMessage *)value;
- (void)removeMessagesObject:(ChatMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
