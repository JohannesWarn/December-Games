//
//  Unit.h
//  RTS
//
//  Created by Johannes Wärn on 17/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Command.h"

@interface Unit : SKShapeNode

@property (nonatomic) CGPoint target;
@property (nonatomic) BOOL shouldMove;

+ (instancetype)unit;
- (NSArray *)commands;

@end

@interface Peasant : Unit
@end