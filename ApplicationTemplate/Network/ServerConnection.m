//
//  ServerConnection.m
//  ApplicationTemplate
//
//  Created by Ali Ajmine on 1/20/16.
//  Copyright (c) 2016 Ali Ajmine. All rights reserved.
//

#import "ServerConnection.h"

@interface ServerConnection () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) ServerConnectionCallback callback;

@property (nonatomic, strong) NSData *receivedData;

@end

@implementation ServerConnection

- (id)initWithCallback:(ServerConnectionCallback)callback {
    
    self = [super init];
    
    if (self) {
        
        if (callback) {
            self.callback = [callback copy];
        }
    }
    
    return self;
}

- (void)makeRequest:(ServerRequest)request withResource:(NSString *)resource withParameters:(NSDictionary *)params
    withJSONPayload:(NSDictionary *)payload {
    
    NSMutableString *urlString = [NSMutableString stringWithString:[ServerConnection buildServerURLForResource:resource]];
    
    if (params) {
        [urlString appendString:[ServerConnection parametersToString:params]];
    }
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                          timeoutInterval:5.0];
    [urlRequest addValue:[ServerConnection getBasicAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
    
    if (payload) {
        NSData *postData = [NSKeyedArchiver archivedDataWithRootObject:payload];
        [urlRequest setHTTPBody:postData];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:@([postData length]).stringValue forHTTPHeaderField:@"Content-Length"];
    }
    
    
    switch (request) {
            
        case SRCreate:
            [urlRequest setHTTPMethod:@"POST"];
            break;
        case SRRetrieve:
            [urlRequest setHTTPMethod:@"GET"];
            break;
        case SRUpdate:
            [urlRequest setHTTPMethod:@"PUT"];
            break;
            
        case SRDelete:
            [urlRequest setHTTPMethod:@"DELETE"];
            break;
        default:
            break;
    }
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        id responseObject;
        
        if (!error) {
            self.receivedData = data;
            responseObject = [self parseResponse];
        }
        
        self.callback(responseObject, error);
    }];
    
    [task resume];
}

- (id)parseResponse {
    // No operation - will be overridden by subclass
    return nil;
}

- (id)getResponseData {
    
    NSError *error;
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.receivedData options:kNilOptions error:&error];
    
    return error ? nil : [json objectForKey:@"data"];
}

#pragma mark - Helper methods

+ (NSString *)parametersToString:(NSDictionary *)paramsDict {
    
    NSMutableString *params = [[NSMutableString alloc] initWithString:@""];
    
    if (paramsDict && paramsDict.count > 0) {
        
        BOOL isFirst = YES;
        
        for (NSString *key in paramsDict) {
            if (isFirst) {
                [params appendString:@"?"];
                isFirst = NO;
            } else {
                [params appendString:@"&"];
            }
            
            [params appendFormat:@"%@=%@",
             [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
             [[[paramsDict valueForKey:key] stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    return params;
}

+ (NSString *)buildServerURLForResource:(NSString *)resource {
    return [NSString stringWithFormat:@"%@://%@/%@", @"http", @"localhost", resource];
}

+ (NSString *)getBasicAuthorizationHeader {
    
    NSData *encodedLoginData = [[[NSString stringWithFormat:@"%@:%@", @"admin", @"password"] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    
    NSString *encodedLoginDataString = [[NSString alloc] initWithData:encodedLoginData encoding:NSUTF8StringEncoding];
    
    return [@"Basic " stringByAppendingString:encodedLoginDataString];
}

@end
