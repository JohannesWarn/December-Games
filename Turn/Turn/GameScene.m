//
//  GameScene.m
//  Turn
//
//  Created by Johannes Wärn on 09/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameScene.h"
#import "Player.h"
#import "Enemy.h"

@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic) Player *player;

@property (nonatomic) SKLabelNode *scoreNode;
@property (nonatomic) int score;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    typeof(self) __weak weakSelf = self;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.friction = 0.0;
    self.physicsBody.collisionBitMask = 1 << 2;
    
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                       [SKAction waitForDuration:5.5 withRange:16.0],
                                                                       [SKAction runBlock:^{ [weakSelf addEnemy]; }]
                                                                       ]]]];
    
    [self setupScoreLabel];
    [self setupPlayer];
}

- (SKShapeNode *)addEnemy
{
    SKShapeNode *enemy = [[Enemy alloc] init];
    [self addChild:enemy];
    
    CGPoint position = CGPointMake(drand48() * self.size.width,
                                   drand48() * self.size.height);
    enemy.position = position;
    
    CGFloat angle = drand48() * M_PI;
    CGFloat magnitude = 20;
    enemy.physicsBody.velocity = CGVectorMake(cos(angle) * magnitude, sin(angle) * magnitude);
    
    return enemy;
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    Enemy *enemy;
    if ([contact.bodyB.node isKindOfClass:[Enemy class]]) {
        enemy = (Enemy *)contact.bodyB.node;
    } else if ([contact.bodyA.node isKindOfClass:[Enemy class]]) {
        enemy = (Enemy *)contact.bodyA.node;
    }
    if (enemy && enemy.kind == self.player.kind) {
        [enemy removeFromParent];
        self.player.kind ++;
        self.player.kind = self.player.kind % 3;
        
        self.score ++;
        [self updateScore];
        
        [self.player updateColor];
    }
}

- (void)setupPlayer
{
    self.player = [[Player alloc] init];
    self.player.physicsBody.velocity = CGVectorMake(11.0, 5.0);
    [self addChild:self.player];
    self.player.position = CGPointMake(self.size.width / 2, self.size.height / 2);
}

- (void)setupScoreLabel
{
    self.scoreNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Thin"];
    self.scoreNode.zPosition = -1;
    self.scoreNode.fontSize = 65;
    self.scoreNode.position = CGPointMake(CGRectGetMidX(self.frame),
                                          CGRectGetMidY(self.frame));
    [self addChild:self.scoreNode];
    [self updateScore];
}

- (void)turn
{
    self.player.direction = (self.player.direction == kLeft ? kRight : kLeft);
}

- (void)updateScore
{
    self.scoreNode.text = [NSString stringWithFormat:@"%@", @(self.score)];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self turn];
}

- (void)update:(NSTimeInterval)currentTime
{
    CGVector velocity = self.player.physicsBody.velocity;
    CGFloat magnitude = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy);
    
    if (magnitude > 0) {
        CGVector normal = CGVectorMake(velocity.dx / magnitude, velocity.dy / magnitude);
        
        CGFloat angle = (M_PI / 20) * (self.player.direction == kLeft ? -1 : 1);
        normal.dx = normal.dx * cos(angle) - normal.dy * sin(angle);
        normal.dy = normal.dx * sin(angle) + normal.dy * cos(angle);
        
        CGVector force = CGVectorMake(normal.dx * 600.0, normal.dy * 600.0);
    
        [self.player.physicsBody applyForce:force];
    }
}

@end
