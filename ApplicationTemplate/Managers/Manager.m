//
//  Manager.m
//  ApplicationTemplate
//
//  Created by Ali Ajmine on 1/20/16.
//  Copyright (c) 2016 Ali Ajmine. All rights reserved.
//

#import "Manager.h"

@implementation Manager

+ (instancetype)instance {
    static Manager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end
