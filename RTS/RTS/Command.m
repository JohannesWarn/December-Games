//
//  Command.m
//  RTS
//
//  Created by Johannes Wärn on 17/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Command.h"

@implementation Command

+ (instancetype)command
{
    return [[self alloc] init];
}

- (NSString *)title
{
    return @"Title";
}

@end

@implementation MoveUnit : Command

- (NSString *)title
{
    return @"Move";
}

@end

@implementation CreatePeasant : Command

- (NSString *)title
{
    return @"Peasant";
}

@end