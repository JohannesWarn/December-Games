//
//  Player.m
//  Tower
//
//  Created by Johannes Wärn on 11/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Player.h"

@implementation Player

+ (Player *)playerWithSize:(CGSize)size
{
    Player *player = [Player shapeNodeWithRectOfSize:size];
    player.fillColor = [SKColor colorWithHue:0.3 saturation:0.8 brightness:0.8 alpha:1.0];
    
    player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
    player.physicsBody.allowsRotation = NO;
    player.physicsBody.linearDamping = 6.0;
    player.physicsBody.friction = 0.1;
    
    return player;
}

@end
