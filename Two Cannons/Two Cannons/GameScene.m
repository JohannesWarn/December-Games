//
//  GameScene.m
//  Two Cannons
//
//  Created by Johannes Wärn on 08/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameScene.h"

@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic) CGPoint initialTouchLocation;

@property (nonatomic) SKShapeNode *leftCannon;
@property (nonatomic) SKShapeNode *rightCannon;

@property (nonatomic) CGFloat cannonRadius;
@property (nonatomic) CGFloat bulletRadius;

@property (nonatomic) NSArray *colors;

@end

@implementation GameScene

static const uint32_t edgeCategory   =  0x1 << 0;
static const uint32_t cannonCategory =  0x1 << 1;
static const uint32_t bulletCategory =  0x1 << 2;
static const uint32_t enemyCategory  =  0x1 << 3;

- (void)didMoveToView:(SKView *)view
{
    typeof(self) __weak weakSelf = self;
    
    self.cannonRadius = self.size.width * 0.15;
    self.bulletRadius = self.cannonRadius * 0.1;
    self.colors = @[[UIColor colorWithHue:0.1 saturation:0.7 brightness:0.7 alpha:1.0],
                    [UIColor colorWithHue:0.6 saturation:0.7 brightness:0.7 alpha:1.0]];
    
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                       [SKAction waitForDuration:0.5 withRange:8],
                                                                       [SKAction runBlock:^{ [weakSelf addEnemy]; }]
                                                                       ]]]];
    
    [self setupWorld];
    [self setupEdge];
    [self setupCannons];
    
    [self addEnemy];
    [self addEnemy];
}

- (void)setupWorld
{
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
}

- (void)setupEdge
{
    CGFloat yExtension = 200.0;
    CGRect rect = CGRectMake(0, -yExtension, self.size.width, self.size.height + yExtension * 2);
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:rect];
    
    self.physicsBody.categoryBitMask = edgeCategory;
    self.physicsBody.friction = 0.0;
}

- (void)setupCannons
{
    SKShapeNode *leftCannon = [self cannon];
    SKShapeNode *rightCannon = [self cannon];
    
    [leftCannon setFillColor:[self.colors objectAtIndex:0]];
    [rightCannon setFillColor:[self.colors objectAtIndex:1]];
    
    [self addChild:leftCannon];
    [self addChild:rightCannon];
    
    CGFloat offsetFromSide = 0.25;
    [leftCannon setPosition:CGPointMake(self.size.width * offsetFromSide, 0)];
    [rightCannon setPosition:CGPointMake(self.size.width * (1 - offsetFromSide), 0)];
    
    self.leftCannon = leftCannon;
    self.rightCannon = rightCannon;
}

- (SKShapeNode *)fireBulletFromCannon:(SKNode *)cannon withVector:(CGVector)vector
{
    CGFloat magnitude = sqrt(vector.dx * vector.dx + vector.dy * vector.dy);
    CGVector normal = CGVectorMake(vector.dx / magnitude, vector.dy / magnitude);
    CGFloat velocityMagnitude = 490.0;
    
    if (magnitude < 4) { return nil; }
    normal.dy = ABS(normal.dy);
    normal.dy = MAX(0.4, normal.dy);
    
    SKShapeNode *bullet = [self bullet];
    [self addChild:bullet];
    
    CGPoint position = cannon.position;
    position.y += self.cannonRadius - self.bulletRadius * 1.5;
    bullet.position = position;
    
    bullet.physicsBody.velocity = CGVectorMake(normal.dx * velocityMagnitude, normal.dy * velocityMagnitude);
    
    return bullet;
}

- (SKShapeNode *)addEnemy
{
    CGFloat angle = drand48() * M_PI;
    CGVector normal = CGVectorMake(cos(angle), sin(angle));
    CGFloat velocityMagnitude = 150 + 60 * drand48();
    
    normal.dy = -ABS(normal.dy);
    
    SKShapeNode *enemy = [self enemy];
    [self addChild:enemy];
    
    CGPoint position = CGPointMake((self.size.width - self.cannonRadius * 0.4 * 2) * drand48() + self.cannonRadius * 0.4,
                                   self.size.height + self.cannonRadius * 0.4);
    enemy.position = position;
    
    enemy.physicsBody.velocity = CGVectorMake(normal.dx * velocityMagnitude, normal.dy * velocityMagnitude);
    
    return enemy;
}

#pragma mark - Nodes

- (SKShapeNode *)cannon
{
    CGFloat radius = self.cannonRadius;
    SKShapeNode *cannon = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    cannon.name = @"cannon";
    cannon.zPosition = 1;
    
    cannon.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    cannon.physicsBody.allowsRotation = NO;
    cannon.physicsBody.pinned = YES;
    
    cannon.physicsBody.categoryBitMask = cannonCategory;
    cannon.physicsBody.collisionBitMask = 0;
    cannon.physicsBody.contactTestBitMask = enemyCategory;
    
    return cannon;
}

- (SKShapeNode *)enemy
{
    CGFloat radius = self.cannonRadius * (0.4 + 0.2 * drand48());
    SKShapeNode *enemy = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    enemy.name = @"enemy";
    enemy.fillColor = [self.colors objectAtIndex:arc4random() % 2];
    
    enemy.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    enemy.physicsBody.allowsRotation = NO;
    enemy.physicsBody.restitution = 1.0;
    enemy.physicsBody.linearDamping = 0.0;
    enemy.physicsBody.friction = 0.0;
    
    enemy.physicsBody.categoryBitMask = enemyCategory;
    enemy.physicsBody.collisionBitMask = enemyCategory | bulletCategory  | edgeCategory;
    
    return enemy;
}

- (SKShapeNode *)bullet
{
    CGFloat radius = self.bulletRadius;
    SKShapeNode *bullet = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    bullet.name = @"bullet";
    
    bullet.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    bullet.physicsBody.allowsRotation = NO;
    bullet.physicsBody.restitution = 1.0;
    bullet.physicsBody.linearDamping = 0.0;
    bullet.physicsBody.mass = 0.005;
    bullet.physicsBody.friction = 0.0;
    
    bullet.physicsBody.categoryBitMask = bulletCategory;
    bullet.physicsBody.collisionBitMask = enemyCategory | edgeCategory;
    bullet.physicsBody.contactTestBitMask = enemyCategory;
    
    return bullet;
}

#pragma mark - SpriteKit event loop

- (void)update:(CFTimeInterval)currentTime
{
    typeof(self) __weak weakSelf = self;
    
    [self enumerateChildNodesWithName:@"bullet" usingBlock:^(SKNode *bullet, BOOL *stop) {
        if (bullet.position.y > weakSelf.size.height + weakSelf.bulletRadius) {
            [bullet removeFromParent];
        }
    }];
    [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *enemy, BOOL *stop) {
        if (enemy.position.y < - weakSelf.cannonRadius) {
            [enemy removeFromParent];
        }
    }];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKShapeNode *enemy;
    SKShapeNode *bullet;
    SKShapeNode *cannon;
    if ([contact.bodyA.node.name isEqualToString:@"enemy"]) {
        enemy = (SKShapeNode *)contact.bodyA.node;
    } else if ([contact.bodyB.node.name isEqualToString:@"enemy"]) {
        enemy = (SKShapeNode *)contact.bodyB.node;
    }
    if ([contact.bodyA.node.name isEqualToString:@"bullet"]) {
        bullet = (SKShapeNode *)contact.bodyA.node;
    } else if ([contact.bodyB.node.name isEqualToString:@"bullet"]) {
        bullet = (SKShapeNode *)contact.bodyB.node;
    }
    if ([contact.bodyA.node.name isEqualToString:@"cannon"]) {
        cannon = (SKShapeNode *)contact.bodyA.node;
    } else if ([contact.bodyB.node.name isEqualToString:@"cannon"]) {
        cannon = (SKShapeNode *)contact.bodyB.node;
    }
    
    if (cannon) {
        [enemy removeFromParent];
    } else if (bullet) {
        if ([bullet.fillColor isEqual:enemy.fillColor]) {
            [enemy removeFromParent];
        }
        [bullet removeFromParent];
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    self.initialTouchLocation = location;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    CGPoint initialLocation = [self initialLocationOfTouch:touch];
    CGVector vector = CGVectorMake(location.x - initialLocation.x, location.y - initialLocation.y);
    
    if (initialLocation.x < self.size.width / 2) {
        SKShapeNode *bullet = [self fireBulletFromCannon:self.leftCannon withVector:vector];
        bullet.fillColor = [self.colors objectAtIndex:0];
    } else {
        SKShapeNode *bullet = [self fireBulletFromCannon:self.rightCannon withVector:vector];
        bullet.fillColor = [self.colors objectAtIndex:1];
    }
}

- (CGPoint)initialLocationOfTouch:(UITouch *)touch
{
    return self.initialTouchLocation;
}

@end
