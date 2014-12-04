//
//  Player.m
//  RPG
//
//  Created by Johannes Wärn on 04/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Player.h"
#import "Enemy.h"
#import "Attack.h"
#import "Item.h"

@implementation Player

- (instancetype)init
{
    if (self = [super init]) {
        self.level = 1;
        self.maxHealth = 30;
        self.maxEnergy = 30;
        self.health = self.maxHealth;
        self.energy = self.maxEnergy;
        
        self.attacks = [self initialAttacks];
        self.items = [[NSMutableArray alloc] initWithArray:@[[[Potion alloc] init]]];
    }
    
    return self;
}

- (void)defeatedEnemy:(Enemy *)enemy
{
    self.experience += enemy.experienceWhenDefeated;
    [self.items addObjectsFromArray:enemy.items];
    
    [self.history insertObject:[NSString stringWithFormat:@"Defeated enemy gaining %@ experience.", @(enemy.experienceWhenDefeated)] atIndex:0];
    if (self.experience > [self experienceRequiredForNextLevel]) {
        [self levelUp];
    }
    if (enemy.items.count > 0) {
        [self.history insertObject:[NSString stringWithFormat:@"And looted %@ items.", @(enemy.items.count)] atIndex:0];
    }
}

- (void)levelUp
{
    self.experience -= [self experienceRequiredForNextLevel];
    self.level ++;
    self.maxEnergy += 2;
    self.maxHealth += 2;
    [self.history insertObject:@"Leveled up." atIndex:0];
    
    if (self.experience > [self experienceRequiredForNextLevel]) {
        [self levelUp];
    }
}

- (NSMutableArray *)initialAttacks
{
    NSMutableArray *attacks = [NSMutableArray array];
    Attack *attack;
    
    attack = [Attack attackWithName:@"Punch"];
    [attack setRequiredEnergy:0];
    [attack setAttackBlock:^(Attack *attack, Actor *player, Actor *enemy) {
        enemy.health -= 5 + self.level;
        return @"Punched enemy giving 5 damage.";
    }];
    [attacks addObject:attack];
    
    attack = [Attack attackWithName:@"Kick"];
    [attack setRequiredEnergy:10];
    [attack setAttackBlock:^(Attack *attack, Actor *player, Actor *enemy) {
        player.energy -= attack.requiredEnergy;
        NSInteger damage = 8 + self.level * (arc4random() % 4);
        enemy.health -= damage;
        return [NSString stringWithFormat:@"Kicked enemy giving %@ damage. Losing 10 energy.", @(damage)];
    }];
    [attacks addObject:attack];
    
    attack = [Attack attackWithName:@"Rest"];
    [attack setRequiredEnergy:0];
    [attack setAttackBlock:^(Attack *attack, Actor *player, Actor *enemy) {
        player.energy += 30;
        return @"Rested restoring 30 energy.";
    }];
    [attacks addObject:attack];
    
    attack = [Attack attackWithName:@"Taunt"];
    [attack setRequiredEnergy:0];
    [attack setAttackBlock:^(Attack *attack, Actor *player, Actor *enemy) {
        enemy.energy -= 20;
        return @"Taunted enemy decreasing enemy energy by 20.";
    }];
    [attacks addObject:attack];
    
    return attacks;
}

- (NSInteger)experienceRequiredForNextLevel
{
    return [self experienceRequiredForLevel:self.level + 1];
}

- (NSInteger)experienceRequiredForLevel:(NSInteger)level
{
    return 5 + level * 3;
}

- (NSString *)debugString
{
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"Player\n"];
    [string appendFormat:@"Level: %@\n", @(self.level)];
    [string appendFormat:@"Health: %@/%@\n", @(self.health), @(self.maxHealth)];
    [string appendFormat:@"Energy: %@/%@\n", @(self.energy), @(self.maxEnergy)];
    [string appendFormat:@"Experience: %@/%@\n", @(self.experience), @([self experienceRequiredForLevel:self.level + 1])];
    
    [string appendString:@"\n"];
    for (NSString *historyString in self.history) {
        [string appendFormat:@"%@\n", historyString];
    }
    
    return [NSString stringWithString:string];
}

@end
