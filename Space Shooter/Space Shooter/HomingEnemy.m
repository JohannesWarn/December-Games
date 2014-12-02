//
//  HomingEnemy.m
//  Space Shooter
//
//  Created by Johannes Wärn on 02/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "HomingEnemy.h"

@implementation HomingEnemy

- (instancetype)init
{
    if (self = [super init]) {
        [self setRadius:16];
        
        [self setBody:[SKShapeNode shapeNodeWithCircleOfRadius:self.radius]];
        [self.body setFillColor:[UIColor greenColor]];
        [self addChild:self.body];
    }
    
    return self;
}

- (SKAction *)mainAction
{
    SKAction *moveTowardsPlayer = [SKAction runBlock:^{
        CGVector distance = CGVectorMake(self.player.position.x - self.position.x,
                                         self.player.position.y - self.position.y);
        CGFloat magnitude = sqrt(distance.dx * distance.dx + distance.dy * distance.dy);
        CGVector direction = CGVectorMake(distance.dx / magnitude, distance.dy / magnitude);
        [self runAction:[SKAction moveBy:direction duration:0.01]];
    }];
    SKAction *followPlayer = [SKAction sequence:@[
                                                  moveTowardsPlayer,
                                                  [SKAction waitForDuration:0.01]
                                                  ]];
    return followPlayer;
}

@end
