//
//  Player.m
//  Tower Tap
//
//  Created by Johannes Wärn on 12/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Player.h"

@implementation Player

+ (instancetype)playerWithSize:(CGSize)size
{
    Player *player = [Player shapeNodeWithRectOfSize:size];
    [player setFillColor:[UIColor colorWithHue:0.05 saturation:0.9 brightness:0.9 alpha:1.0]];
    [player setStrokeColor:nil];
    [player setDirection:DirectionRight];
    [player setVelocity:CGVectorMake(0, 0)];
    [player setSize:size];
    
    return player;
}

@end
