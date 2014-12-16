//
//  GameScene.m
//  No Smooch
//
//  Created by Johannes Wärn on 15/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameScene.h"

@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic) int score;
@property (nonatomic) SKLabelNode *scoreLabel;

@property (nonatomic) SKShapeNode *player;
@property (nonatomic) SKShapeNode *lastBody;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];
    
    [self.physicsWorld setGravity:CGVectorMake(0, 0)];
    [self.physicsWorld setContactDelegate:self];
    
    [self setupPlayer];
    [self setupScore];
    [self addBody];
    [self addBody];
    [self addBody];
}

- (SKShapeNode *)addBody
{
    CGFloat radius = 32;
    SKShapeNode *body = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    [self addChild:body];
    [body setName:@"body"];
    [body setFillColor:[UIColor colorWithHue:0.63 saturation:0.7 brightness:0.7 alpha:0.75]];
    [body setPosition:CGPointMake(self.size.width * drand48(), self.size.height * drand48())];
    
    [body setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:radius]];
    [body.physicsBody setCategoryBitMask:2];
    [body.physicsBody setRestitution:0.9];
    [body.physicsBody setFriction:0.0];
    [body.physicsBody setPinned:YES];
    
    SKFieldNode *fieldNode = [SKFieldNode radialGravityField];
    [body addChild:fieldNode];
    
    return body;
}

- (void)setupPlayer
{
    CGFloat radius = 12;
    _player = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    [self addChild:_player];
    [_player setName:@"player"];
    [_player setFillColor:[UIColor colorWithHue:0.43 saturation:0.7 brightness:0.7 alpha:1.0]];
    [_player setPosition:CGPointMake(self.size.width / 2, radius * 5)];
    
    [_player setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:radius]];
    [_player.physicsBody setCategoryBitMask:1];
    [_player.physicsBody setContactTestBitMask:2];
    [_player.physicsBody setRestitution:0.9];
    [_player.physicsBody setFriction:0.0];
    [_player.physicsBody setLinearDamping:0.4];
    
    [_player.physicsBody applyForce:CGVectorMake(0, 10)];
}

- (void)setupScore
{
    _score = 0;
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Thin"];
    [_scoreLabel setZPosition:-1];
    
    [_scoreLabel setText:[NSString stringWithFormat:@"%@", @(_score)]];
    [_scoreLabel setFontSize:65];
    [_scoreLabel setPosition:CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame))];
    
    [self addChild:_scoreLabel];
}

- (void)update:(NSTimeInterval)currentTime
{
    if (_player.position.x < -20 || _player.position.x > self.size.width + 20 ||
        _player.position.y < -20 || _player.position.y > self.size.height + 20) {
        
    }
}

- (void)restart
{
    [self removeAllChildren];
    
    [self setupPlayer];
    [self setupScore];
    [self addBody];
    [self addBody];
    [self addBody];
    _lastBody = nil;
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKShapeNode *body = (SKShapeNode *)(contact.bodyB.node.children.count > 0 ? contact.bodyB.node : contact.bodyA.node);
    if (body.children.count > 0) {
        [_lastBody setFillColor:[UIColor colorWithHue:0.63 saturation:0.7 brightness:0.7 alpha:0.75]];
        _lastBody = body;
        [_lastBody setFillColor:[UIColor colorWithHue:0.63 saturation:0.7 brightness:0.7 alpha:1.0]];
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_lastBody != nil) {
        [_lastBody removeAllChildren];
        [_lastBody setFillColor:[UIColor colorWithHue:0.63 saturation:0.7 brightness:0.7 alpha:0.05]];
        _lastBody = nil;
        _score ++;
        [_scoreLabel setText:[NSString stringWithFormat:@"%@", @(_score)]];
        
        [self addBody];
    } else if ([[touches anyObject] tapCount] == 3) {
        [self restart];
    }
}

@end
