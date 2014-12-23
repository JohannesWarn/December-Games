//
//  GameScene.m
//  Bounce
//
//  Created by Johannes Wärn on 22/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

#import "GameScene.h"

@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic) CMMotionManager *manager;
@property (nonatomic) CMAcceleration accelerationGravity;

@property (nonatomic) SKShapeNode *player;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view
{
    [self setupPlayer];
    [self setupMotionManager];
    
    [self.physicsWorld setContactDelegate:self];
}

- (SKShapeNode *)pad
{
    CGFloat width = 50 + arc4random() % 140;
    CGFloat height = 10;
    CGRect rect = CGRectMake(-width / 2, -height / 2, width, height);
    SKShapeNode *pad = [SKShapeNode shapeNodeWithRect:rect];
    [pad setName:@"pad"];
    [pad setFillColor:[UIColor whiteColor]];
    
    [pad setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(width, height)]];
    [pad.physicsBody setAffectedByGravity:NO];
    [pad.physicsBody setLinearDamping:0.0];
    [pad.physicsBody setCategoryBitMask:(1 << 1)];
    [pad.physicsBody setCollisionBitMask:0];
    
    return pad;
}

- (void)setupPlayer
{
    CGFloat radius = 13;
    _player = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    [_player setName:@"player"];
    [_player setPosition:CGPointMake(self.size.width / 2, 5 * self.size.height / 6)];
    [_player setFillColor:[SKColor colorWithHue:0.345 saturation:0.751 brightness:0.982 alpha:1.000]];
    [_player setStrokeColor:_player.fillColor];
    
    [_player setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:radius]];
    [_player.physicsBody setRestitution:1.0];
    [_player.physicsBody setAllowsRotation:NO];
    [_player.physicsBody setFriction:0.0];
    [_player.physicsBody setLinearDamping:0.0];
    [_player.physicsBody setAffectedByGravity:NO];
    [_player.physicsBody setContactTestBitMask:(1 << 1)];
    [self addChild:_player];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_player.physicsBody setAffectedByGravity:YES];
}

- (void)setupMotionManager
{
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    [manager setGyroUpdateInterval:0.1];
    [manager startGyroUpdates];
    
    GameScene * __weak weakSelf = self;
    if (manager.deviceMotionAvailable) {
        manager.deviceMotionUpdateInterval = 0.01f;
        [manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                     withHandler:^(CMDeviceMotion *data, NSError *error) {
                                         weakSelf.accelerationGravity = data.gravity;
                                     }];
    }
    
    [self setManager:manager];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKShapeNode *player;
    SKShapeNode *pad;
    if ([contact.bodyA.node.name isEqualToString:@"player"]) {
        player = (SKShapeNode *)contact.bodyA.node;
    } else if ([contact.bodyB.node.name isEqualToString:@"player"]) {
        player = (SKShapeNode *)contact.bodyB.node;
    }
    if ([contact.bodyA.node.name isEqualToString:@"pad"]) {
        pad = (SKShapeNode *)contact.bodyA.node;
    } else if ([contact.bodyB.node.name isEqualToString:@"pad"]) {
        pad = (SKShapeNode *)contact.bodyB.node;
    }

    [pad removeFromParent];
}

- (void)update:(CFTimeInterval)currentTime
{
    CGFloat rotation = MIN(MAX(_accelerationGravity.y, -0.25), 0.25);
    CGFloat magnitude = rotation * ABS(rotation) * 50.0;
    [_player.physicsBody applyImpulse:CGVectorMake(magnitude, 0.0)];
    [_player.physicsBody applyImpulse:CGVectorMake(_player.physicsBody.velocity.dx * -0.004, 0)];
    
    if (arc4random() % 100 < 2) {
        SKShapeNode *pad = [self pad];
        [self addChild:pad];
        [pad setPosition:CGPointMake(100, 20 + arc4random() % 200)];
        
        [pad.physicsBody applyImpulse:CGVectorMake(2.0, 0)];
    }
    
    if (_player.position.y < -50) {
        [_player removeFromParent];
        [self setupPlayer];
    }
    
    [self enumerateChildNodesWithName:@"pad" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x < - 100 || node.position.x > self.size.width + 100) {
            [node removeFromParent];
        }
    }];
}

@end
