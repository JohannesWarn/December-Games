//
//  Item.m
//  RPG
//
//  Created by Johannes Wärn on 04/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Item.h"
#import "Actor.h"

@implementation Item

+ (instancetype)itemWithName:(NSString *)name
{
    Item *item = [[Item alloc] init];
    [item setName:name];
    return item;
}

@end

@implementation Potion : Item

- (instancetype)init
{
    if (self = [super init]) {
        self.name = @"Potion";
        self.itemBlock = ^NSString *(Item *item, Actor *user, Actor *otherActor) {
            user.health += 20;
            return @"Used potion and restored 20 health.";
        };
    }
    
    return self;
}

@end