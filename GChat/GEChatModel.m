//
//  GEChatModel.m
//  Grouvent
//
//  Created by Blankwonder on 11/26/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "GEChatModel.h"
#import "SocketIOPacket.h"
#import "NSDate+Utilities.h"

static const NSInteger kDatabaseVersion = 5;

@interface GEChatModel () {
    NSMutableDictionary *_connectCallbackBlockMap;
}

@end

@interface SocketIOWithChatRoom : SocketIO
@property (weak) ChatRoom *chatRoom;
@end
@implementation SocketIOWithChatRoom
@end

@implementation GEChatModel

+ (GEChatModel *)sharedInstance
{
    static dispatch_once_t pred;
    __strong static GEChatModel *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[GEChatModel alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initDataContext];
        _connectCallbackBlockMap = [NSMutableDictionary dictionary];
        _socketIOs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)initDataContext {
    NSURL *databaseURL = [NSURL fileURLWithPath:[[GEStroageManager sharedInstance] databasePath]];
    NSInteger nowDatabaseVersion = [[NSUserDefaults standardUserDefaults] integerForKey:GEUserDefaultsKeyDatabaseVersion];
    if (nowDatabaseVersion != kDatabaseVersion) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:databaseURL error:nil];
        [[NSUserDefaults standardUserDefaults] setInteger:kDatabaseVersion forKey:GEUserDefaultsKeyDatabaseVersion];
    }
    _dataContext = [[KDXData alloc] initWithDatabasePath:databaseURL
                                                    objectModel:nil
                                         automaticResetDatabase:YES];
}

- (BOOL)addNewMessageInContext:(NSManagedObjectContext *)context
                      chatRoom:(ChatRoom *)chatRoom
                            id:(NSNumber *)id
                          text:(NSString *)text
                    senderName:(NSString *)senderName
                          type:(NSString *)type
                          date:(NSDate *)date
{
    NSNumber *lastMessageID = [self lastMessageID:chatRoom inContext:context];
    if (lastMessageID.intValue + 1 != id.intValue) {
        KDXClassLog(@"WARNING: Attempt to add message with illegal id");
        return NO;
    }
    ChatMessage *chatMessage = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage"
                                                                            inManagedObjectContext:context];
    chatMessage.text = text;
    chatMessage.senderName = senderName;
    chatMessage.id = id;
    chatMessage.type = type;
    chatMessage.date = date;
    chatMessage.sectionDate = [date dateAtStartOfDay];
    [chatRoom addMessagesObject:chatMessage];

    return YES;
}

- (NSNumber *)lastMessageID:(ChatRoom *)chatRoom
                  inContext:(NSManagedObjectContext *)context {
    NSArray *resultArray = [self lastMessage:chatRoom count:1 inContext:context];
    
    NSNumber *result = [(ChatMessage *)[resultArray lastObject] id];
    if (!result)
        result = [NSNumber numberWithInt:0];
    return result;
}

- (NSArray *)lastMessage:(ChatRoom *)room
                   count:(NSInteger)count 
               inContext:(NSManagedObjectContext *)context {
    NSError *error = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.fetchLimit = count;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatMessage"
                                        inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"chatRoom = %@", room]];
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id"
                                                                   ascending:NO
                                                                    selector:nil];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateDescriptor]];
    NSArray *resultArray = [context executeFetchRequest:fetchRequest
                                                  error:&error];
    if (error) {
        KDXClassLog(@"Error occered when perform fetch %@, %@", error, [error localizedDescription]);
    }
    return resultArray;
}

- (ChatMessage *)messageWithID:(NSString *)messageID
                     inContext:(NSManagedObjectContext *)context {
    NSError *error = nil;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatMessage"
                                        inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id = %@", messageID]];
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id"
                                                                   ascending:NO
                                                                    selector:nil];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateDescriptor]];
    NSArray *resultArray = [context executeFetchRequest:fetchRequest
                                                  error:&error];
    if (error) {
        KDXClassLog(@"Error occered when perform fetch %@, %@", error, [error localizedDescription]);
    }
    return resultArray.lastObject;
}

- (ChatRoom *)chatRoomWithID:(NSString *)roomId context:(NSManagedObjectContext *)context{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.fetchLimit = 1;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatRoom"
                                        inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id = %@", roomId]];
    NSArray *partys = [context executeFetchRequest:fetchRequest
                                             error:&error];
    if (error) {
        KDXClassLog(@"Error occered when perform fetch %@, %@", error, [error localizedDescription]);
        return nil;
    }
    NSAssert(partys.count <= 1, @"Duplicate party id found!");

    return [partys lastObject];
}

- (void)syncPartyChatLog:(ChatRoom *)room {
    NSNumber *lastMessageId = [self lastMessageID:room
                                        inContext:_dataContext.context_MainThread];
    NSNumber *startId = [NSNumber numberWithInt:lastMessageId.intValue + 1];
    [self syncPartyChatLog:room
             startMessageID:startId];
}

- (void)syncPartyChatLog:(ChatRoom *)room
          startMessageID:(NSNumber *)startMessageID {
    NSString *roomId = room.id;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", room.serverAddress]];
    [[GEAPIClient defaultClient]
     getChatRoomMessagesWithRoomID:roomId
     startID:startMessageID
     endID:nil
     count:nil
     serverAddress:url
     success:^(GEAPIRequestOperation *operation, NSDictionary *result) {
         __block BOOL allSuccess = YES;
         [_dataContext
          asyncOperation:^(NSManagedObjectContext *context) {
              ChatRoom *chatRoom = [self chatRoomWithID:roomId context:context];
              NSArray *messages = result[@"chats"];
              for (NSDictionary *newMessage in messages) {
                  BOOL success = [self addNewMessageInContext:context
                                                     chatRoom:chatRoom
                                                           id:newMessage[@"id"]
                                                         text:newMessage[@"body"]
                                                   senderName:newMessage[@"senderName"]
                                                         type:newMessage[@"type"]
                                                         date:[NSDate dateWithTimeIntervalSince1970:[newMessage[@"time"] doubleValue]]];
                  if (!success) {
                      allSuccess = NO;
                  }
              }
          } completeBlock:^(BOOL changed){
              if (!allSuccess) {
                  [self syncPartyChatLog:room];
              }
          }];
    } failure:^(GEAPIRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)connectChatRoom:(ChatRoom *)chatRoom callback:(void(^)(BOOL success, NSError *error))block{
    KDXClassLog(@"Connecting to chatroom: %@", chatRoom.id);
    SocketIOWithChatRoom *socketIO = _socketIOs[chatRoom.id];
    if (!socketIO) {
        socketIO = [[SocketIOWithChatRoom alloc] initWithDelegate:self];
        socketIO.chatRoom = chatRoom;
        _socketIOs[chatRoom.id] = socketIO;
    }

    if (socketIO.isConnected) {
        block(YES, nil);
        return;
    }

    if (block) {
        _connectCallbackBlockMap[chatRoom.id] = [block copy];
    }

    if (socketIO.isConnecting) {
        return;
    }

    NSArray *serverAddressComp = [chatRoom.serverAddress componentsSeparatedByString:@":"];

    [socketIO connectToHost:serverAddressComp[0]
                     onPort:[serverAddressComp[1] intValue]
                 withParams:@{@"roomId": chatRoom.id, @"signature": chatRoom.joinSignature, @"nickname": chatRoom.selfNickname}];
}

- (BOOL)isChatRoomConnected:(ChatRoom *)chatRoom {
    SocketIOWithChatRoom *socketIO = _socketIOs[chatRoom.id];
    return socketIO.isConnected;
}

- (void)disconnectChatRoom:(ChatRoom *)chatRoom {
    SocketIOWithChatRoom *socketIO = _socketIOs[chatRoom.id];
    if (socketIO.isConnected) {
        [socketIO disconnect];
    }
}

- (void)disconnectAll {
    [_socketIOs enumerateKeysAndObjectsUsingBlock:^(id key, SocketIOWithChatRoom *socketIO, BOOL *stop) {
        if (socketIO.isConnected) {
            [socketIO disconnect];
        }
    }];
}

- (void)socketIODidConnect:(SocketIOWithChatRoom *)socket {
    KDXClassLog(@"SocketIO did connect");
    void(^block)(BOOL success, NSError *error) = _connectCallbackBlockMap[socket.chatRoom.id];
    if (block) {
        block(YES, nil);
    }
    [_connectCallbackBlockMap removeObjectForKey:socket.chatRoom.id];
}

- (BOOL)sendMessage:(NSString *)message chatRoom:(ChatRoom *)room {
    if (![self isChatRoomConnected:room])
        return NO;
    SocketIOWithChatRoom *socketIO = _socketIOs[room.id];

    NSString *roomId = room.id;
    [socketIO
     sendEvent:@"chat message"
     withData:[NSDictionary dictionaryWithObjectsAndKeys:message, @"body", nil]
     andAcknowledge:^(id argsData) {
         NSNumber *messageID = argsData;
         KDXClassLog(@" SocketIO Chat message acknowledge, message id: %@", messageID);
         __block BOOL success;
         [_dataContext
          asyncOperation:^(NSManagedObjectContext *context) {
              ChatRoom *chatRoom = [self chatRoomWithID:roomId context:context];
              success = [self addNewMessageInContext:context
                                  chatRoom:chatRoom
                                        id:messageID
                                      text:message
                                senderName:chatRoom.selfNickname
                                      type:@"chat"
                                      date:[NSDate date]];
          } completeBlock:^(BOOL changed) {
              if (!success) {
                  [self syncPartyChatLog:room];
              }
          }];
     }];

    return YES;
}

- (void)socketIO:(SocketIOWithChatRoom *)socket didReceiveEvent:(SocketIOPacket *)packet {
    NSDictionary *args = [[packet args] lastObject];
    NSString *roomId = socket.chatRoom.id;
    NSString *messageID = args[@"id"];
    KDXClassLog(@"SocketIO did receive new message, id: %@, room id:%@", messageID, roomId);

    __block BOOL success;
    [_dataContext
     asyncOperation:^(NSManagedObjectContext *context) {
         ChatRoom *chatRoom = [self chatRoomWithID:roomId context:context];

         success = [self addNewMessageInContext:context
                                       chatRoom:chatRoom
                                             id:args[@"id"]
                                           text:args[@"body"]
                                     senderName:args[@"senderName"]
                                           type:args[@"type"]
                                           date:[NSDate dateWithTimeIntervalSince1970:[args[@"time"] doubleValue]]];
     } completeBlock:^(BOOL changed){
         if (!success) {
             [self syncPartyChatLog:socket.chatRoom];
         }
     }];
}

- (void)socketIODidDisconnect:(SocketIOWithChatRoom *)socket {
    KDXClassLog(@"SocketIO did disconnect, room id: %@", socket.chatRoom.id);
}

- (void) socketIOHandshakeFailed:(SocketIOWithChatRoom *)socket {
    KDXClassLog(@"SocketIO handshake failed, room id: %@", socket.chatRoom.id);
    void(^block)(BOOL success, NSError *error) = _connectCallbackBlockMap[socket.chatRoom.id];
    if (block) {
        block(NO, nil);
    }
    [_connectCallbackBlockMap removeObjectForKey:socket.chatRoom.id];
}

- (void) socketIO:(SocketIOWithChatRoom *)socket failedToConnectWithError:(NSError *)error {
    KDXClassLog(@"SocketIO failed to connect, room id: %@, error: %@", socket.chatRoom.id, error);
    void(^block)(BOOL success, NSError *error) = _connectCallbackBlockMap[socket.chatRoom.id];
    if (block) {
        block(NO, nil);
    }
    [_connectCallbackBlockMap removeObjectForKey:socket.chatRoom.id];
}

static NSDate *APIResultDateTypeConvert(id APIResult) {
    if ([APIResult isKindOfClass:[NSNumber class]] || [APIResult isKindOfClass:[NSString class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[APIResult doubleValue]];
    } else {
        return nil;
    }
}

- (void)createNewChatRoomWithTitle:(NSString *)title
                   sponsorNickname:(NSString *)sponsorNickname
                           success:(void (^)(NSString *roomId,NSString *shortlink))success
                           failure:(void (^)(NSError *error))failure {
    [[GEAPIClient defaultClient]
     createNewChatRoomWithTitle:title
     sponsorNickname:sponsorNickname
     success:^(GEAPIRequestOperation *operation, NSDictionary *result) {
         NSString *shortlink = result[@"shortlink"];
         NSString *roomId = result[@"roomId"];
         [_dataContext asyncOperation:^(NSManagedObjectContext *context) {
             ChatRoom *chatRoom = (ChatRoom *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatRoom"
                                                                            inManagedObjectContext:context];
             chatRoom.createDate = APIResultDateTypeConvert(result[@"createDate"]);
             chatRoom.title = title;
             chatRoom.id = roomId;
             chatRoom.serverAddress = result[@"serverAddress"];
             chatRoom.joinSignature = result[@"signature"];
             chatRoom.lastReadMessageID = nil;
             chatRoom.shortlink = shortlink;
             chatRoom.selfNickname = sponsorNickname;
             chatRoom.joinDate = [NSDate date];
        } completeBlock:^(BOOL changed) {
            success(roomId, shortlink);
        }];
    } failure:^(GEAPIRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)joinExistChatroomWithRoomID:(NSString *)roomId
                           nickname:(NSString *)nickname
                            success:(void (^)())success
                            failure:(void (^)(NSError *error))failure {
    [[GEAPIClient defaultClient] joinExistChatroomWithRoomID:roomId nickname:nickname success:^(GEAPIRequestOperation *operation, NSDictionary *result) {
        if (operation.response.statusCode == 200) {
            [_dataContext asyncOperation:^(NSManagedObjectContext *context) {
                ChatRoom *chatRoom = (ChatRoom *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatRoom"
                                                                               inManagedObjectContext:context];
                chatRoom.createDate = APIResultDateTypeConvert(result[@"createDate"]);
                chatRoom.title = result[@"title"];
                chatRoom.id = roomId;
                chatRoom.serverAddress = result[@"serverAddress"];
                chatRoom.joinSignature = result[@"signature"];
                chatRoom.lastReadMessageID = nil;
                chatRoom.shortlink = result[@"shortlink"];
                chatRoom.selfNickname = nickname;
                chatRoom.joinDate = [NSDate date];
            } completeBlock:^(BOOL changed) {
                success();
            }];
        } else {
            failure(nil);
        }
    } failure:^(GEAPIRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

@end
