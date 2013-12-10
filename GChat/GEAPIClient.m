//
//  GEAPIClient.m
//  Grouvent
//
//  Created by Blankwonder on 10/25/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "GEAPIClient.h"
#import "NSString+MD5.h"
#import "NSDate+KDXFormatDate.h"

@implementation GEAPIClient

NSString *const kGEAPIPrefix = @"http://gchat.in:8001";

+ (GEAPIClient *)defaultClient {
    static dispatch_once_t pred;
    __strong static GEAPIClient *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[GEAPIClient alloc] initWithDefaultBaseURL];
    });	
    
    return sharedInstance;
}

- (id)initWithDefaultBaseURL {
    self = [self initWithBaseURL:[NSURL URLWithString:kGEAPIPrefix]];
    if (self) {
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self registerHTTPOperationClass:[GEAPIRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"];
        [self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"GChat iOS %@", version]];
    }
    return self;
}

- (GEAPIRequestOperation *)createNewChatRoomWithTitle:(NSString *)title
                                      sponsorNickname:(NSString *)sponsorNickname
                                              success:(GEAPIRequestSuccessBlock)success
                                              failure:(GEAPIRequestFailureBlock)failure {
    return [self requestOperationWithMethod:@"POST"
                                       path:@"chatroom"
                                 parameters:@{@"title": title, @"sponsorNickname": sponsorNickname}
                        expectedStatusCodes:[NSIndexSet indexSetWithIndex:200]
                                    success:success
                                    failure:failure];
}

- (GEAPIRequestOperation *)joinExistChatroomWithRoomID:(NSString *)roomId
                                              nickname:(NSString *)nickname
                                               success:(GEAPIRequestSuccessBlock)success
                                               failure:(GEAPIRequestFailureBlock)failure {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:200];
    [indexSet addIndex:409];
    return [self requestOperationWithMethod:@"POST"
                                       path:[NSString stringWithFormat:@"chatroom/%@/members", roomId]
                                 parameters:@{@"nickname": nickname}
                        expectedStatusCodes:indexSet
                                    success:success
                                    failure:failure];
}

- (GEAPIRequestOperation *)getChatRoomMessagesWithRoomID:(NSString *)roomId
                                                 startID:(NSNumber *)startID
                                                   endID:(NSNumber *)endID
                                                   count:(NSNumber *)count
                                           serverAddress:(NSURL *)serverAddress
                                                 success:(GEAPIRequestSuccessBlock)success
                                                 failure:(GEAPIRequestFailureBlock)failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (startID) {
        [parameters setObject:startID forKey:@"startID"];
    }
    if (endID) {
        [parameters setObject:endID forKey:@"endID"];
    }
    if (count) {
        [parameters setObject:count forKey:@"count"];
    }

    GEAPIRequestOperation *operation = [self requestOperationWithMethod:@"GET"
                                                                   path:@"chatroom"
                                                             parameters:parameters
                                                    expectedStatusCodes:[NSIndexSet indexSetWithIndex:200]
                                                                success:success
                                                                failure:failure];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"chatroom/%@/messages", roomId]
                        relativeToURL:serverAddress];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:@"?%@", AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding)]];

    [(NSMutableURLRequest *)operation.request setURL:url];
    
    return operation;
}

- (GEAPIRequestOperation *)requestOperationWithMethod:(NSString *)method
                                                 path:(NSString *)path
                                           parameters:(NSDictionary *)parameters
                                  expectedStatusCodes:(NSIndexSet *)expectedStatusCode
                                              success:(void (^)(GEAPIRequestOperation *operation, id responseObject))success
                                              failure:(void (^)(GEAPIRequestOperation *operation, NSError *error))failure
{
	NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:parameters];
    request.timeoutInterval = 15;
    GEAPIRequestOperation *operation = [[GEAPIRequestOperation alloc] initWithRequest:request];
    void (^_success)(AFHTTPRequestOperation *operation, id responseObject) = (void (^)(AFHTTPRequestOperation *operation, id responseObject))success;
    void (^_failure)(AFHTTPRequestOperation *operation, id responseObject) = (void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
    [operation setCompletionBlockWithSuccess:_success failure:_failure];
    operation.expectedStatusCodesIfSuccess = expectedStatusCode;
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:nil];
    [self enqueueHTTPRequestOperation:operation];
    return operation;
}

@end
