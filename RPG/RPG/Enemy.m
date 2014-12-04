//
//  Enemy.m
//  RPG
//
//  Created by Johannes Wärn on 04/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Enemy.h"
#import "Attack.h"
#import "Item.h"

@implementation Enemy

- (Attack *)attackAgainstActor:(Actor *)actor
{
    if (self.energy == self.maxEnergy) {
        return [self.attacks objectAtIndex:0];
    } else if (self.energy <= [[self.attacks objectAtIndex:0] requiredEnergy]) {
        return [self.attacks objectAtIndex:1];
    } else {
        return [self.attacks objectAtIndex:(NSInteger)arc4random() % self.attacks.count];
    }
}

@end

@implementation Bat

- (instancetype)init
{
    if (self = [super init]) {
        self.name = @"Bat";
        self.level = 1 + arc4random() % 6;
        self.maxHealth = 10 + self.level * 2;
        self.maxEnergy = 10 + self.level * 2;
        self.health = self.maxHealth;
        self.energy = self.maxEnergy;
        self.experienceWhenDefeated = 5 + self.level * 1;
        
        self.attacks = [self initialAttacks];
        if (arc4random() % 5 < 2) {
            [self.items addObject:[[Potion alloc] init]];
        }
    }
    
    return self;
}

- (NSMutableArray *)initialAttacks
{
    NSMutableArray *attacks = [NSMutableArray array];
    Attack *attack;
    
    attack = [Attack attackWithName:@"Bite"];
    [attack setRequiredEnergy:10];
    [attack setAttackBlock:^(Attack *attack, Actor *enemy, Actor *player) {
        enemy.energy -= attack.requiredEnergy;
        player.health -= 5 + enemy.level;
        return @"Bit player giving 5 damage.";
    }];
    [attacks addObject:attack];
    
    attack = [Attack attackWithName:@"Rest"];
    [attack setRequiredEnergy:0];
    [attack setAttackBlock:^(Attack *attack, Actor *enemy, Actor *player) {
        enemy.energy += 10;
        return @"Rested restoring 10 energy.";
    }];
    [attacks addObject:attack];
    
    return attacks;
}

@end

@implementation Bear

- (instancetype)init
{
    if (self = [super init]) {
        self.name = @"Bear";
        self.level = 1 + arc4random() % 9;
        self.maxHealth = 20 + self.level * 2;
        self.maxEnergy = 20 + self.level * 2;
        self.health = self.maxHealth;
        self.energy = self.maxEnergy;
        self.experienceWhenDefeated = 10 + self.level * 3;
        
        self.attacks = [self initialAttacks];
        if (arc4random() % 5 < 2) {
            [self.items addObject:[[Potion alloc] init]];
        }
    }
    
    return self;
}

- (NSMutableArray *)initialAttacks
{
    NSMutableArray *attacks = [NSMutableArray array];
    Attack *attack;
    
    attack = [Attack attackWithName:@"Slash"];
    [attack setRequiredEnergy:10];
    [attack setAttackBlock:^(Attack *attack, Actor *enemy, Actor *player) {
        enemy.energy -= attack.requiredEnergy;
        NSInteger damage = 6 + arc4random() % 3 + self.level;
        player.health -= damage;
        return [NSString stringWithFormat:@"Slashed player giving %@ damage.", @(damage)];
    }];
    [attacks addObject:attack];
    
    attack = [Attack attackWithName:@"Rest"];
    [attack setRequiredEnergy:0];
    [attack setAttackBlock:^(Attack *attack, Actor *enemy, Actor *player) {
        enemy.energy += 10;
        return @"Rested restoring 10 energy.";
    }];
    [attacks addObject:attack];
    
    return attacks;
}

@end