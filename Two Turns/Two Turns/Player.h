//
//  Player.h
//  Turn 2
//
//  Created by Johannes Wärn on 09/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    kLeft,
    kRight
} Direction;

@interface Player : SKShapeNode

@property (nonatomic) CGFloat radius;
@property (nonatomic) int kind;
@property (nonatomic) Direction direction;

- (void)updateColor;

@end
