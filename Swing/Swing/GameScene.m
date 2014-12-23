//
//  GameScene.m
//  Swing
//
//  Created by Johannes Wärn on 19/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameScene.h"

@interface GameScene ()

@property (nonatomic) int score;
@property (nonatomic) SKLabelNode *scoreLabel;

@property (nonatomic) SKNode *worldNode;
@property (nonatomic) SKNode *cameraNode;

@property (nonatomic) SKShapeNode *player;
@property (nonatomic) SKShapeNode *rope;
@property (nonatomic) BOOL drawRope;
@property (nonatomic) SKPhysicsJointLimit *joint;
@property (nonatomic) CGPoint jointPoint;
@property (nonatomic) CGFloat nextCoin;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view
{
    [self setupWorld];
    [self setupPlayer];
    [self setupScore];
}

- (void)setupWorld
{
    _nextCoin = 0;
    self.anchorPoint = CGPointMake (0.5,0.5);
    
    _worldNode = [SKNode node];
    _worldNode.physicsBody = [SKPhysicsBody bodyWithBodies:nil];
    [_worldNode.physicsBody setDynamic:NO];
    [self addChild:_worldNode];
    
    [self setupCamera];
}

- (void)setupCamera
{
    _cameraNode = [SKNode node];
    _cameraNode.name = @"camera";
    [_worldNode addChild:_cameraNode];
}


- (void)setupPlayer
{
    CGFloat radius = 15;
    _player = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    [_player setName:@"player"];
    [_player setFillColor:[SKColor colorWithHue:0.2 saturation:0.8 brightness:0.8 alpha:1.0]];
    [_player setStrokeColor:_player.fillColor];
    [_player setPosition:CGPointMake(-self.size.width / 4, 0)];
    
    [_player setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:radius]];
    [_player.physicsBody setLinearDamping:0.04];
    [_player.physicsBody setAllowsRotation:NO];
    
    [_worldNode addChild:_player];
    
    _jointPoint = CGPointMake(_player.position.x + 30,
                              _player.position.y + 100);
    
    _joint = [SKPhysicsJointLimit jointWithBodyA:_player.physicsBody
                                           bodyB:_player.parent.physicsBody
                                         anchorA:_player.position
                                         anchorB:_jointPoint];
    [self.physicsWorld addJoint:_joint];
    
    _drawRope = YES;
    _rope = [SKShapeNode node];
    [_rope setLineWidth:3.0];
    [_rope setLineCap:kCGLineCapRound];
    [_rope setZPosition:-1.0];
    [_rope setStrokeColor:[UIColor colorWithHue:0.1 saturation:0.6 brightness:0.6 alpha:1.0]];
    [_worldNode addChild:_rope];
}

- (void)setupScore
{
    _score = 0;
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Thin"];
    
    [_scoreLabel setText:[NSString stringWithFormat:@"%i", _score]];
    [_scoreLabel setFontSize:65];
    [_scoreLabel setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
    [_scoreLabel setZPosition:-2.0];
    [self addChild:_scoreLabel];
}

- (SKShapeNode *)coin
{
    CGFloat radius = 15;
    SKShapeNode *coin = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    [coin setName:@"coin"];
    [coin setFillColor:[SKColor colorWithHue:0.08 saturation:0.8 brightness:0.8 alpha:1.0]];
    [coin setStrokeColor:coin.fillColor];
    [coin setPosition:CGPointMake(-self.size.width / 4, 0)];
    
    [coin setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:radius]];
    [coin.physicsBody setDynamic:NO];
    
    return coin;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _drawRope = YES;
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        _jointPoint = [_worldNode convertPoint:location fromNode:self];
        
        [self.physicsWorld removeJoint:_joint];
        _joint = [SKPhysicsJointLimit jointWithBodyA:_player.physicsBody
                                               bodyB:_player.parent.physicsBody
                                             anchorA:_player.position
                                             anchorB:_jointPoint];
        [self.physicsWorld addJoint:_joint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _drawRope = NO;
    [self.physicsWorld removeJoint:_joint];
}

- (void)update:(NSTimeInterval)currentTime
{
    [_player.physicsBody applyImpulse:CGVectorMake(_player.physicsBody.velocity.dx / 6000, 0)];
    
    if (_cameraNode.position.x + self.size.width / 2 > _nextCoin) {
        _nextCoin += 50 + arc4random() % 150;
        SKShapeNode *coin = [self coin];
        [_worldNode addChild:coin];
        coin.position = CGPointMake(_nextCoin, arc4random() % (int)self.size.height - self.size.height / 2);
    }
    
    [_worldNode enumerateChildNodesWithName:@"coin" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x < _cameraNode.position.x - (self.size.width / 2 + 50)) {
            [node removeFromParent];
            _score++;
            [_scoreLabel setText:[NSString stringWithFormat:@"%i", _score]];
        }
    }];
    
    if (_player.position.y < -self.size.height / 2) {
        [_worldNode removeFromParent];
        [_scoreLabel removeFromParent];
        
        [self setupWorld];
        [self setupPlayer];
        [self setupScore];
    }
}

- (void)didFinishUpdate
{
    CGMutablePathRef path = CGPathCreateMutable();
    if (_drawRope) {
        [_rope setStrokeColor:[UIColor colorWithHue:0.1 saturation:0.6 brightness:0.6 alpha:1.0]];
    } else {
        [_rope setStrokeColor:[UIColor clearColor]];
    }
    CGPathMoveToPoint(path, nil, _player.position.x, _player.position.y);
    CGPathAddLineToPoint(path, nil, _jointPoint.x, _jointPoint.y);
    [_rope setPath:path];
    
    
    CGPoint position = _cameraNode.position;
    if (_player.position.x > _cameraNode.position.x) {
        position.x += (_player.position.x - _cameraNode.position.x) / 10;
    }
    position.x += self.size.width / 500;
    _cameraNode.position = position;
    
    [self centerOnNode:_cameraNode];
}

- (void)centerOnNode:(SKNode *)node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x,
                                       node.parent.position.y - cameraPositionInScene.y);
}

@end
