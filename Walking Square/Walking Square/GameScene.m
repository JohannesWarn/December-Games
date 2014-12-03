//
//  GameScene.m
//  Walking Square
//
//  Created by Johannes Wärn on 03/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

#import "GameScene.h"

@interface GameScene ()

@property (nonatomic) CGSize playerSize;
@property (nonatomic) SKShapeNode *player;

@property (nonatomic) CMMotionManager *manager;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view
{
    [self setupPlayer];
    [self setupGround];
    
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    [manager setGyroUpdateInterval:0.1];
    [manager startGyroUpdates];
    
    GameScene * __weak weakSelf = self;
    if (manager.deviceMotionAvailable) {
        manager.deviceMotionUpdateInterval = 0.01f;
        [manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                     withHandler:^(CMDeviceMotion *data, NSError *error) {
                                         CGFloat offset = (weakSelf.playerSize.width / 2) * (data.gravity.y > 0 ? 1 : -1);
                                         CGPoint globalPoint = CGPointMake(weakSelf.player.position.x + offset,
                                                                           weakSelf.player.position.y - (weakSelf.playerSize.width / 2));
                                         CGPoint point = [weakSelf.player convertPoint:globalPoint fromNode:weakSelf];
                                         
                                         [weakSelf.player.physicsBody applyForce:CGVectorMake(0, data.gravity.y * 120)
                                                                         atPoint:point];
                                     }];
    }
    
    [self setManager:manager];
}

- (void)setupPlayer
{
    UIColor *playerColor = [UIColor colorWithHue:0.12 saturation:0.76 brightness:0.86 alpha:1];
    _playerSize = CGSizeMake(50, 50);
    _player = [SKShapeNode shapeNodeWithRectOfSize:_playerSize];
    [_player setFillColor:playerColor];
    [_player setStrokeColor:playerColor];
    
    _player.position = CGPointMake(self.size.width * 0.5,
                                   self.size.height * 0.5);
    [_player setName:@"player"];
    [_player setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:_playerSize center:CGPointZero]];
    [_player.physicsBody setAngularDamping:70.0];
    [_player.physicsBody setFriction:25.0];
    
    [self addChild:_player];
}

- (void)setupGround
{
    CGPoint p1 = CGPointMake(0, 20 + arc4random() % 30);
    CGPoint p2 = CGPointMake(p1.x + 60 + arc4random() % 30, 20 + arc4random() % 30);
    while (p1.x < self.size.width) {
        SKShapeNode *ground = [self groundFromPoint:p1 toPoint:p2];
        [self addChild:ground];
        
        p1 = p2;
        
        p2 = CGPointMake(p1.x + 60 + arc4random() % 30, 20 + arc4random() % 30);
    }
}

- (SKShapeNode *)groundFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    UIColor *groundColor = [UIColor colorWithHue:0.32 saturation:0.76 brightness:0.52 alpha:1];
    CGPoint groundPoints[] = {
        CGPointMake(startPoint.x, 0),
        startPoint,
        endPoint,
        CGPointMake(endPoint.x, 0),
        CGPointMake(startPoint.x, 0),
    };
    SKShapeNode *ground = [SKShapeNode shapeNodeWithPoints:groundPoints count:5];
    [ground setFillColor:groundColor];
    [ground setStrokeColor:groundColor];
    
    [ground setName:@"ground"];
    [ground setPhysicsBody:[SKPhysicsBody bodyWithEdgeFromPoint:startPoint toPoint:endPoint]];
    
    return ground;
}

/*
#pragma mark - Touches

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        CGVector distance = CGVectorMake(previousLocation.x - location.x,
                                         previousLocation.y - location.y);
        //        CGVector force = CGVectorMake(distance.dx * 1.5, distance.dy * 3);
        
        //        [_player.physicsBody applyForce:force atPoint:CGPointMake(_playerSize.width / 2, 0)];
        [_player.physicsBody applyTorque:distance.dy * 0.05];
    }
}
 */

@end
