//
//  Attack.h
//  RPG
//
//  Created by Johannes Wärn on 04/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Actor;

@interface Attack : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger requiredEnergy;
@property (nonatomic, copy) NSString *(^attackBlock)(Attack *attack, Actor *attacker, Actor *defender);

+ (instancetype)attackWithName:(NSString *)name;

@end
