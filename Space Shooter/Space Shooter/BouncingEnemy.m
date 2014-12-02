//
//  BouncingEnemy.m
//  Space Shooter
//
//  Created by Johannes Wärn on 02/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "BouncingEnemy.h"

@interface BouncingEnemy ()

@property (nonatomic) CGVector direction;

@end

@implementation BouncingEnemy

- (instancetype)init
{
    if (self = [super init]) {
        [self setRadius:12];
        
        [self setBody:[SKShapeNode shapeNodeWithCircleOfRadius:self.radius]];
        [self.body setFillColor:[UIColor blueColor]];
        [self addChild:self.body];
        
        CGFloat angle = drand48() * M_PI;
        [self setDirection:CGVectorMake(cos(angle), sin(angle))];
    }
    
    return self;
}

- (SKAction *)mainAction
{
    SKAction *moveInDirection = [SKAction runBlock:^{
        if ((self.position.x < 0 && self.direction.dx < 0) ||
            (self.position.x > self.parent.frame.size.width && self.direction.dx > 0)) {
            CGVector direction = self.direction;
            direction.dx *= -1;
            self.direction = direction;
        }
        if ((self.position.y < 0 && self.direction.dy < 0) ||
            (self.position.y > self.parent.frame.size.height && self.direction.dy > 0)) {
            CGVector direction = self.direction;
            direction.dy *= -1;
            self.direction = direction;
        }
        
        [self runAction:[SKAction moveBy:self.direction duration:0.01]];
    }];
    SKAction *action = [SKAction sequence:@[
                                            moveInDirection,
                                            [SKAction waitForDuration:0.01]
                                            ]];
    return action;
}


@end
