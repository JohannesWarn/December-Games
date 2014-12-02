//
//  Player.m
//  Space Shooter
//
//  Created by Johannes Wärn on 02/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Player.h"

@interface Player ()

@property (nonatomic) CGFloat radius;

@property (nonatomic) SKShapeNode *body;

@end

@implementation Player

+ (instancetype)player
{
    Player *player = [Player node];
    if (player != nil) {
        [player setRadius:8];
        
        [player setBody:[SKShapeNode shapeNodeWithCircleOfRadius:player.radius]];
        [player.body setFillColor:[UIColor redColor]];
        
        [player addChild:player.body];
    }
    return player;
}

@end
