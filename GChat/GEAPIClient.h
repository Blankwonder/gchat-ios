//
//  GEAPIClient.h
//  Grouvent
//
//  Created by Blankwonder on 10/25/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "AFNetworking.h"
#import "GEAPIRequestOperation.h"

typedef void ( ^GEAPIRequestSuccessBlock ) ( GEAPIRequestOperation *operation , NSDictionary *result );
typedef void ( ^GEAPIRequestFailureBlock ) ( GEAPIRequestOperation *operation , NSError *error );

@interface GEAPIClient : AFHTTPClient

+ (GEAPIClient *)defaultClient;

- (id)initWithDefaultBaseURL;

- (GEAPIRequestOperation *)createNewChatRoomWithTitle:(NSString *)title
                                      sponsorNickname:(NSString *)sponsorNickname
                                              success:(GEAPIRequestSuccessBlock)success
                                     failure:(GEAPIRequestFailureBlock)failure;

- (GEAPIRequestOperation *)getChatRoomMessagesWithRoomID:(NSString *)roomId
                                                 startID:(NSNumber *)startID
                                                   endID:(NSNumber *)endID
                                                   count:(NSNumber *)count
                                           serverAddress:(NSURL *)serverAddress
                                                 success:(GEAPIRequestSuccessBlock)success
                                                 failure:(GEAPIRequestFailureBlock)failure;

- (GEAPIRequestOperation *)joinExistChatroomWithRoomID:(NSString *)roomId
                                              nickname:(NSString *)nickname
                                               success:(GEAPIRequestSuccessBlock)success
                                               failure:(GEAPIRequestFailureBlock)failure;
@end
