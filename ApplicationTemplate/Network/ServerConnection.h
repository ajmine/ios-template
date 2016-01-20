//
//  ServerConnection.h
//  ApplicationTemplate
//
//  Created by Ali Ajmine on 1/20/16.
//  Copyright (c) 2016 Ali Ajmine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerConnection : NSObject

typedef void (^ ServerConnectionCallback)(id responseObject, NSError *error);


typedef enum {
    SRCreate,
    SRRetrieve,
    SRUpdate,
    SRDelete
} ServerRequest;


typedef enum {
    RCSuccess = 200,
    RCOK = 201,
    RCCreated = 202,
    RCAccepted = 203,
    
    RCBadRequest = 400,
    RCUnauthorized = 401,
    RCForbidden = 403,
    RCNotFound = 404,
    
} ResponseCode;

- (id)initWithCallback:(ServerConnectionCallback)callback;

- (void)makeRequest:(ServerRequest)request withResource:(NSString *)resource withParameters:(NSDictionary *)params
    withJSONPayload:(NSDictionary *)payload;

- (id)getResponseData;

@end
