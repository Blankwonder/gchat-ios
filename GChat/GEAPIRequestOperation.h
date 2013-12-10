//
//  GEAPIRequestOperation.h
//  Grouvent
//
//  Created by Blankwonder on 10/25/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

extern NSString* const GEAPIRequestOperationErrorDomain;
typedef enum {
    GEAPIRequestOperationResponseSourceIllegalError = 1000,
    GEAPIRequestOperationServerInternalError = 1001,
    GEAPIRequestOperationNotExpectedStatusCodeError = 1002,
    GEAPIRequestOperationAuthorizationFailureError = 2401,
    GEAPIRequestOperationRateLimitingError = 2420
} GEAPIRequestOperationErrorType;

@interface GEAPIRequestOperation : AFHTTPRequestOperation

@property (readonly, nonatomic, strong) id responseJSON;
@property NSIndexSet *expectedStatusCodesIfSuccess;

@end
