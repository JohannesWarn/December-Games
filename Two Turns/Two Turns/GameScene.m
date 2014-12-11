//
//  GameScene.m
//  Turn 2
//
//  Created by Johannes Wärn on 09/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameScene.h"
#import "Player.h"
#import "Enemy.h"

@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic) Player *player1;
@property (nonatomic) Player *player2;

@property (nonatomic) SKLabelNode *scoreNode1;
@property (nonatomic) SKLabelNode *scoreNode2;
@property (nonatomic) int score1;
@property (nonatomic) int score2;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.friction = 0.0;
    self.physicsBody.collisionBitMask = 1 << 2;
    
    for (int i = 0; i < 3; i++) {
        [self addEnemyOfKind:0];
        [self addEnemyOfKind:1];
    }
    
    [self setupScoreLabels];
    [self setupPlayers];
}

- (SKShapeNode *)addEnemyOfKind:(int)kind
{
    Enemy *enemy = [[Enemy alloc] init];
    [self addChild:enemy];
    enemy.kind = kind;
    [enemy updateColor];
    
    CGFloat yInset = 0.05;
    CGPoint position = CGPointMake(0, 0);
    position.x = drand48() * self.size.width * 0.3 + self.size.width * 0.15;
    position.y = kind == 0 ? self.size.height * yInset : self.size.height * (1.0 - yInset);
    enemy.position = position;
    
    return enemy;
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    Enemy *enemy;
    Player *player;
    if ([contact.bodyB.node isKindOfClass:[Enemy class]]) {
        enemy = (Enemy *)contact.bodyB.node;
    } else if ([contact.bodyA.node isKindOfClass:[Enemy class]]) {
        enemy = (Enemy *)contact.bodyA.node;
    }
    
    if ([contact.bodyB.node isKindOfClass:[Player class]]) {
        player = (Player *)contact.bodyB.node;
    } else if ([contact.bodyA.node isKindOfClass:[Player class]]) {
        player = (Player *)contact.bodyA.node;
    }
    
    if (enemy && enemy.kind != player.kind) {
        if ([player isEqual:self.player1]) {
            self.score2 ++;
        } else {
            self.score1 ++;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addEnemyOfKind:enemy.kind];
        });
        [self updateScores];
        
        [enemy removeFromParent];
    }
}

- (void)setupPlayers
{
    self.player1 = [[Player alloc] init];
    self.player1.physicsBody.velocity = CGVectorMake(11.0, 5.0);
    [self addChild:self.player1];
    self.player1.position = CGPointMake(self.size.width / 2, self.size.height / 3);
    
    self.player2 = [[Player alloc] init];
    self.player2.physicsBody.velocity = CGVectorMake(-11.0, -5.0);
    [self addChild:self.player2];
    self.player2.position = CGPointMake(self.size.width / 2, 2 * self.size.height / 3);
    self.player2.kind = 1;
    [self.player2 updateColor];
}

- (void)setupScoreLabels
{
    self.scoreNode1 = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Thin"];
    self.scoreNode1.zPosition = -1;
    self.scoreNode1.fontSize = 65;
    self.scoreNode1.position = CGPointMake(self.size.width / 2, self.size.height / 3);
    self.scoreNode1.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [self addChild:self.scoreNode1];
    
    self.scoreNode2 = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Thin"];
    self.scoreNode2.zPosition = -1;
    self.scoreNode2.fontSize = 65;
    self.scoreNode2.position = CGPointMake(self.size.width / 2, 2 * self.size.height / 3);
    self.scoreNode2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.scoreNode2.zRotation = M_PI;
    
    [self addChild:self.scoreNode2];
    
    [self updateScores];
}

- (void)turnPlayer:(Player *)player
{
    player.direction = (player.direction == kLeft ? kRight : kLeft);
}

- (void)updateScores
{
    self.scoreNode1.text = [NSString stringWithFormat:@"%@", @(self.score1)];
    self.scoreNode2.text = [NSString stringWithFormat:@"%@", @(self.score2)];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (location.y < self.size.height / 2) {
            [self turnPlayer:self.player1];
        } else {
            [self turnPlayer:self.player2];
        }
    }
}

- (void)applyTurnForceToPlayer:(Player *)player
{
    CGVector velocity = player.physicsBody.velocity;
    CGFloat magnitude = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy);
    
    if (magnitude > 0) {
        CGVector normal = CGVectorMake(velocity.dx / magnitude, velocity.dy / magnitude);
        
        CGFloat angle = (M_PI / 20) * (player.direction == kLeft ? -1 : 1);
        normal.dx = normal.dx * cos(angle) - normal.dy * sin(angle);
        normal.dy = normal.dx * sin(angle) + normal.dy * cos(angle);
        
        CGVector force = CGVectorMake(normal.dx * 600.0, normal.dy * 600.0);
        
        [player.physicsBody applyForce:force];
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    [self applyTurnForceToPlayer:self.player1];
    [self applyTurnForceToPlayer:self.player2];
}

@end
