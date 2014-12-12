//
//  Player.h
//  Tower Tap
//
//  Created by Johannes Wärn on 12/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    DirectionNone,
    DirectionLeft,
    DirectionRight
} Direction;

@interface Player : SKShapeNode

@property (nonatomic) Direction direction;
@property (nonatomic) CGVector velocity;
@property (nonatomic) CGSize size;

+ (instancetype)playerWithSize:(CGSize)size;

@end
