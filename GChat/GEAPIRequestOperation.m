//
//  GEAPIRequestOperation.m
//  Grouvent
//
//  Created by Blankwonder on 10/25/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "GEAPIRequestOperation.h"

static dispatch_queue_t GE_api_json_request_operation_processing_queue;
static dispatch_queue_t json_request_operation_processing_queue() {
    if (GE_api_json_request_operation_processing_queue == NULL) {
        GE_api_json_request_operation_processing_queue = dispatch_queue_create("com.suixingtech.grouvent.networking.json-request.processing", 0);
    }
    
    return GE_api_json_request_operation_processing_queue;
}

NSString *const GEAPIRequestOperationErrorDomain = @"com.suixingtech.grouvent.api.operation.error";

@interface GEAPIRequestOperation ()
@property (readwrite, nonatomic, strong) id responseJSON;
@property (readwrite, nonatomic, strong) NSError *JSONError;
@end

@implementation GEAPIRequestOperation
@synthesize responseJSON = _responseJSON;
@synthesize JSONError = _JSONError;

- (id)responseJSON {
    if (!_responseJSON && [self.responseData length] > 0 && [self isFinished] && !self.JSONError) {
        NSError *error = nil;
        
        if ([self.responseData length] == 0) {
            self.responseJSON = nil;
        } else {
            self.responseJSON = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
        }
        
        self.JSONError = error;
    }
    
    return _responseJSON;
}

- (NSError *)error {
    if (_JSONError) {
        return _JSONError;
    } else {
        return [super error];
    }
}

#pragma mark - AFHTTPRequestOperation

+ (NSSet *)acceptableContentTypes {
    return nil;
}

+ (NSIndexSet *)acceptableStatusCodes {
    return nil;
}

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    return YES;
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    self.completionBlock = ^ {
        if ([self isCancelled]) {
            return;
        }
        
        KDXClassLog(@"API Request Completed: %@ %@", self.request.HTTPMethod, self.request.URL.path);
        if (self.error) {
            KDXClassLog(@"API Request Failed: %@", self.error.localizedDescription);
            if (failure) {
                dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                    failure(self, self.error);
                });
            }
            return;
        }
        
        NSString *responseString = self.responseString;
        if (NO && responseString.length < 2000) {
            KDXClassLog(@"API Response status code: %d, body: %@", self.response.statusCode, self.responseString);
        } else {
            KDXClassLog(@"API Response status code: %d, body string length: %d.", self.response.statusCode, responseString.length);
        }
        
        if (self.response.statusCode >= 500) {
            if (failure) {
                NSError *error = [NSError errorWithDomain:GEAPIRequestOperationErrorDomain
                                                     code:GEAPIRequestOperationServerInternalError
                                                 userInfo:nil];
                dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                    failure(self, error);
                });
            }
            return;
        }
        
        if (self.expectedStatusCodesIfSuccess &&
            ![self.expectedStatusCodesIfSuccess containsIndex:self.response.statusCode]) {
            if (self.response.statusCode == 401) {
                NSError *error = [NSError errorWithDomain:GEAPIRequestOperationErrorDomain
                                                     code:GEAPIRequestOperationAuthorizationFailureError
                                                 userInfo:nil];
                dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                    if (failure) {
                        failure(self, error);
                    }
                });
            } else if (self.response.statusCode == 420) {
                if (failure) {
                    NSError *error = [NSError errorWithDomain:GEAPIRequestOperationErrorDomain
                                                         code:GEAPIRequestOperationRateLimitingError
                                                     userInfo:nil];
                    dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                        failure(self, error);
                    });
                }
            } else {
                if (failure) {
                    NSError *error = [NSError errorWithDomain:GEAPIRequestOperationErrorDomain
                                                         code:GEAPIRequestOperationNotExpectedStatusCodeError
                                                     userInfo:nil];
                    dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                        failure(self, error);
                    });
                }
            }
            return;
        }
        
        dispatch_async(json_request_operation_processing_queue(), ^{
            id JSON = self.responseJSON;
            
            if (self.JSONError) {
                KDXClassLog(@"API Request Failed: JSON parser failed (%@)", self.JSONError.localizedDescription);
                if (failure) {
                    dispatch_async(self.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                        failure(self, self.error);
                    });
                }
            } else {
                if (success) {
                    dispatch_async(self.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                        success(self, JSON);
                    });
                }
            }
        });
    };
#pragma clang diagnostic pop
}

- (NSString *)errorPromptionFromResponseJSON {
    if ([self.responseJSON isKindOfClass:[NSDictionary class]]) {
        return [self.responseJSON objectForKey:@"error"];
    } else {
        return nil;
    }
}

- (void)start {
    [super start];
    KDXClassLog(@"Start API Request: %@ %@", self.request.HTTPMethod, self.request.URL);
    if ([self.request.HTTPMethod isEqualToString:@"POST"]||[self.request.HTTPMethod isEqualToString:@"PUT"]) {
        KDXClassLog(@"API Request body: %@", [[NSString alloc] initWithData:self.request.HTTPBody  encoding:NSUTF8StringEncoding]);
    }
}

@end
