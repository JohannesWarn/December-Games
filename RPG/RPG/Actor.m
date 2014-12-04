//
//  Actor.m
//  RPG
//
//  Created by Johannes Wärn on 04/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Actor.h"
#import "Attack.h"
#import "Item.h"

@implementation Actor

- (instancetype)init
{
    if (self = [super init]) {
        self.history = [NSMutableArray array];
        self.items = [NSMutableArray array];
        self.attacks = [NSMutableArray array];
    }
    
    return self;
}

- (BOOL)performAttack:(Attack *)attack againstActor:(Actor *)actor
{
    if (self.energy >= attack.requiredEnergy) {
        [self.history insertObject:attack.attackBlock(attack, self, actor) atIndex:0];
        self.energy = MIN(self.energy, self.maxEnergy);
        self.energy = MAX(self.energy, 0);
        self.health = MIN(self.health, self.maxHealth);
        
        actor.energy = MAX(actor.energy, 0);
        
        return YES;
    }
    return NO;
}

- (BOOL)useItem:(Item *)item againstActor:(Actor *)actor
{
    [self.history insertObject:item.itemBlock(item, self, actor) atIndex:0];
    [self.items removeObject:item];
    
    self.energy = MIN(self.energy, self.maxEnergy);
    self.energy = MAX(self.energy, 0);
    self.health = MIN(self.health, self.maxHealth);
    
    actor.energy = MIN(actor.energy, actor.maxEnergy);
    actor.energy = MAX(actor.energy, 0);

    return self;
}

- (NSString *)debugString
{
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"%@\n", self.name];
    [string appendFormat:@"Level: %@\n", @(self.level)];
    [string appendFormat:@"Health: %@/%@\n", @(self.health), @(self.maxHealth)];
    [string appendFormat:@"Energy: %@/%@\n", @(self.energy), @(self.maxEnergy)];
    
    [string appendString:@"\n\n"];
    for (NSString *historyString in self.history) {
        [string appendFormat:@"%@\n", historyString];
    }
    
    return [NSString stringWithString:string];
}

@end
