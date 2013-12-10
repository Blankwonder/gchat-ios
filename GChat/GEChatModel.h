//
//  GEChatModel.h
//  Grouvent
//
//  Created by Blankwonder on 11/26/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"
#import "ChatMessage.h"
#import "ChatRoom.h"
#import "KDXData.h"

@interface GEChatModel : NSObject <SocketIODelegate> {
    NSMutableDictionary *_socketIOs;
    KDXData *_dataContext;
}

+ (GEChatModel *)sharedInstance;

- (void)connectChatRoom:(ChatRoom *)chatRoom callback:(void(^)(BOOL success, NSError *error))block;
- (BOOL)isChatRoomConnected:(ChatRoom *)chatRoom;
- (void)disconnectChatRoom:(ChatRoom *)chatRoom;
- (void)disconnectAll;

- (BOOL)sendMessage:(NSString *)message chatRoom:(ChatRoom *)room;


- (NSArray *)lastMessage:(ChatRoom *)room
                   count:(NSInteger)count
               inContext:(NSManagedObjectContext *)context;

- (void)syncPartyChatLog:(ChatRoom *)room;

- (void)createNewChatRoomWithTitle:(NSString *)title
                   sponsorNickname:(NSString *)sponsorNickname
                           success:(void (^)(NSString *roomId,NSString *shortlink))success
                           failure:(void (^)(NSError *error))failure;

- (void)joinExistChatroomWithRoomID:(NSString *)roomId
                           nickname:(NSString *)nickname
                            success:(void (^)())success
                            failure:(void (^)(NSError *error))failure;


@property (readonly) KDXData *dataContext;

@end
