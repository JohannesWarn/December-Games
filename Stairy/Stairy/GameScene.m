//
//  GameScene.m
//  Stairy
//
//  Created by Johannes Wärn on 23/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameScene.h"

@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic) SKShapeNode *player;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view
{
    [self setupWorld];
    [self setupPlayer];
}

- (void)setupWorld
{
    [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
    
    SKShapeNode *block = [self blockOfSize:CGSizeMake(300, 60)];
    [self addChild:block];
    [block setPosition:CGPointMake(150, 30)];
    
    block = [self blockOfSize:CGSizeMake(280, 60)];
    [self addChild:block];
    [block setPosition:CGPointMake(530, 30)];
    
    SKShapeNode *movableBlock = [self movableBlockOfSize:CGSizeMake(60, 50)];
    [self addChild:movableBlock];
    [movableBlock setPosition:CGPointMake(340, 25)];
    
    SKPhysicsJoint *joint = [SKPhysicsJointSliding jointWithBodyA:self.physicsBody
                                                            bodyB:movableBlock.physicsBody
                                                           anchor:movableBlock.position
                                                             axis:CGVectorMake(0, 1)];
    [self.physicsWorld addJoint:joint];
    
    movableBlock = [self movableBlockOfSize:CGSizeMake(60, 10)];
    [self addChild:movableBlock];
    [movableBlock setPosition:CGPointMake(200, 200)];
    
    joint = [SKPhysicsJointSliding jointWithBodyA:self.physicsBody
                                            bodyB:movableBlock.physicsBody
                                           anchor:movableBlock.position
                                             axis:CGVectorMake(0.5, -1)];
    [self.physicsWorld addJoint:joint];
}

- (SKShapeNode *)blockOfSize:(CGSize)size
{
    SKShapeNode *block = [SKShapeNode shapeNodeWithRectOfSize:size];
    [block setName:@"block"];
    
    [block setFillColor:[SKColor colorWithHue:0.3 saturation:0.1 brightness:0.4 alpha:1.0]];
    
    [block setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:size]];
    [block.physicsBody setDynamic:NO];
    return block;
}

- (SKShapeNode *)movableBlockOfSize:(CGSize)size
{
    SKShapeNode *block = [SKShapeNode shapeNodeWithRectOfSize:size];
    [block setName:@"movableBlock"];
    
    [block setFillColor:[SKColor colorWithHue:0.3 saturation:0.6 brightness:0.8 alpha:1.0]];
    
    [block setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:size]];
    [block.physicsBody setAffectedByGravity:NO];
    [block.physicsBody setAllowsRotation:NO];
    [block.physicsBody setMass:100.0];
    return block;
}

- (void)setupPlayer
{
    CGSize size = CGSizeMake(30, 30);
    _player = [SKShapeNode shapeNodeWithRectOfSize:size];
    [_player setName:@"player"];
    [self addChild:_player];
    
    [_player setPosition:CGPointMake(100, 100)];
    [_player setFillColor:[SKColor colorWithHue:0.6 saturation:0.7 brightness:0.6 alpha:1.0]];
    
    [_player setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:size]];
    [_player.physicsBody setLinearDamping:4.0];
    [_player.physicsBody setRestitution:0.5];
    [_player.physicsBody setAllowsRotation:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        CGVector delta = CGVectorMake(location.x - previousLocation.x, location.y - previousLocation.y);
        [self enumerateChildNodesWithName:@"movableBlock" usingBlock:^(SKNode *node, BOOL *stop) {
            [node.physicsBody applyForce:CGVectorMake(delta.dx * 10000, delta.dy * 10000)];
        }];
    }
}

- (void)update:(CFTimeInterval)currentTime
{
    CGFloat direction = _player.physicsBody.velocity.dx < 0 ? -1 : 1;
    CGFloat magnitude = direction * 0.5;
    [_player.physicsBody applyImpulse:CGVectorMake(magnitude, 0)];
}

@end
