//
//  Attack.m
//  RPG
//
//  Created by Johannes Wärn on 04/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Attack.h"

@implementation Attack

+ (instancetype)attackWithName:(NSString *)name
{
    Attack *attack = [[Attack alloc] init];
    [attack setName:name];
    return attack;
}

@end
