//
//  Enemy.h
//  RPG
//
//  Created by Johannes Wärn on 04/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Actor.h"

@interface Enemy : Actor

@property (nonatomic) NSInteger experienceWhenDefeated;

- (Attack *)attackAgainstActor:(Actor *)actor;

@end

@interface Bat : Enemy
@end

@interface Bear : Enemy
@end
