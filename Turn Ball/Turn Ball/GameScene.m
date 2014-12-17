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

@property (nonatomic) NSArray *players;
@property (nonatomic) Enemy *ball;

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
    
    [self setupBall];
    [self setupGoals];
    [self setupScoreLabels];
}

- (void)setupGoals
{
    CGFloat radius = 20;
    CGPoint points[] = {
        CGPointMake(self.size.width / 2 - (100 + radius), 0),
        CGPointMake(self.size.width / 2 + (100 + radius), 0),
        CGPointMake(self.size.width / 2 - (100 + radius), self.size.height),
        CGPointMake(self.size.width / 2 + (100 + radius), self.size.height)
    };
    for (int i = 0; i < 4; i++) {
        SKShapeNode *goalPost = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
        [goalPost setFillColor:[UIColor colorWithHue:(1.0 / 2.0) * (i / 2)
                                          saturation:0.46
                                          brightness:0.68
                                               alpha:1.0]];
        [goalPost setPosition:points[i]];
        [goalPost setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:radius]];
        [goalPost.physicsBody setPinned:YES];
        [goalPost.physicsBody setUsesPreciseCollisionDetection:YES];
        [goalPost.physicsBody setCategoryBitMask:1 << 3];
        [self addChild:goalPost];
    }
}

- (void)setupBall
{
    Enemy *enemy = [[Enemy alloc] init];
    [self addChild:enemy];
    
    CGPoint position = CGPointMake(0, 0);
    position.x = self.size.width / 2;
    position.y = self.size.height / 2;
    enemy.position = position;
    
    self.ball = enemy;
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ABS(weakSelf.ball.physicsBody.velocity.dx) < 10) {
            if (weakSelf.ball.position.x < self.size.width / 2) {
                [weakSelf.ball.physicsBody applyForce:CGVectorMake( 50, 0)];
            } else {
                [weakSelf.ball.physicsBody applyForce:CGVectorMake(-50, 0)];
            }
        }
    });
    if (ABS(_ball.position.x - self.size.width / 2) < 100) {
        if (_ball.position.y < self.size.height / 2) {
            self.score2 ++;
        } else {
            self.score1 ++;
        }
        
        [self updateScores];
    }
}

- (void)setupPlayers:(int)numberOfPlayers
{
    CGPoint points[] = {
        CGPointMake(self.size.width / 2 - 60, self.size.height / 4),
        CGPointMake(self.size.width / 2 - 60, 3 * self.size.height / 4),
        CGPointMake(self.size.width / 2 + 60, self.size.height / 4),
        CGPointMake(self.size.width / 2 + 60, 3 * self.size.height / 4)
    };
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < numberOfPlayers; i++) {
        Player *player = [[Player alloc] init];
        CGFloat direction = i % 2 ? -1 : 1;
        player.physicsBody.velocity = CGVectorMake(11.0 * direction, 5.0 * direction);
        [self addChild:player];
        player.position = points[i];
        player.number = i / 2.0;
        player.kind = i % 2;
        [player updateColor];
        [array addObject:player];
    }
    self.players = [NSArray arrayWithArray:array];
}

- (void)setupScoreLabels
{
    self.scoreNode1 = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Thin"];
    self.scoreNode1.zPosition = -1;
    self.scoreNode1.fontSize = 65;
    self.scoreNode1.position = CGPointMake(self.size.width / 2, self.size.height / 4);
    self.scoreNode1.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [self addChild:self.scoreNode1];
    
    self.scoreNode2 = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Thin"];
    self.scoreNode2.zPosition = -1;
    self.scoreNode2.fontSize = 65;
    self.scoreNode2.position = CGPointMake(self.size.width / 2, 3 * self.size.height / 4);
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
            if (location.x > self.size.width / 2 && self.players.count >= 3) {
                [self turnPlayer:[self.players objectAtIndex:2]];
            } else {
                [self turnPlayer:[self.players objectAtIndex:0]];
            }
        } else {
            if (location.x > self.size.width / 2 && self.players.count >= 4) {
                [self turnPlayer:[self.players objectAtIndex:3]];
            } else {
                [self turnPlayer:[self.players objectAtIndex:1]];
            }
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
    for (Player *player in self.players) {
        [self applyTurnForceToPlayer:player];
    }
}

@end
