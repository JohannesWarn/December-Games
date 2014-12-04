//
//  Actor.h
//  RPG
//
//  Created by Johannes Wärn on 04/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Attack;
@class Item;

@interface Actor : NSObject

@property (nonatomic) NSString *name;

@property (nonatomic) NSInteger level;
@property (nonatomic) NSInteger maxHealth;
@property (nonatomic) NSInteger health;
@property (nonatomic) NSInteger maxEnergy;
@property (nonatomic) NSInteger energy;

@property (nonatomic) NSMutableArray *attacks;
@property (nonatomic) NSMutableArray *items;

@property (nonatomic) NSMutableArray *history;

- (NSString *)debugString;
- (BOOL)performAttack:(Attack *)attack againstActor:(Actor *)actor;
- (BOOL)useItem:(Item *)item againstActor:(Actor *)actor;

@end
