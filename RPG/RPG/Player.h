//
//  Player.h
//  RPG
//
//  Created by Johannes Wärn on 04/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"

@class Enemy;

@interface Player : Actor

@property (nonatomic) NSInteger experience;

- (NSInteger)experienceRequiredForLevel:(NSInteger)level;
- (void)defeatedEnemy:(Enemy *)enemy;

@end
