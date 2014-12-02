//
//  Enemy.m
//  Space Shooter
//
//  Created by Johannes Wärn on 02/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy

- (instancetype)init
{
    if (self = [super init]) {
        [self setScale:0.0];
        [self runAction:[SKAction scaleTo:1.0 duration:0.1]];
    }
    
    return self;
}

- (SKAction *)mainAction
{
    return nil;
}

@end
