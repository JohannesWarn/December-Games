//
//  GameScene.m
//  Space Shooter
//
//  Created by Johannes Wärn on 02/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameScene.h"
#import "Player.h"
#import "Enemy.h"
#import "HomingEnemy.h"
#import "BouncingEnemy.h"

@interface GameScene ()

@property (nonatomic) Player *player;
@property (nonatomic) SKShapeNode *crosshair;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    [self setupPlayer];
}

- (void)setupPlayer
{
    [self setPlayer:[Player player]];
    [self addChild:self.player];
    [self.player setName:@"player"];
    [self.player setPosition:CGPointMake(self.frame.size.width * 0.5,
                                         self.frame.size.height * 0.5)];
}

- (void)setupCrosshair
{
    [self setCrosshair:[SKShapeNode shapeNodeWithCircleOfRadius:3.0]];
    [self addChild:self.crosshair];
    [self.crosshair setPosition:self.player.position];
    [self.crosshair setName:@"crosshair"];
}

- (SKAction *)addEnemiesAction
{
    SKAction *wait = [SKAction waitForDuration:0.0 withRange:4.0];
    SKAction *addEnemy = [SKAction runBlock:^{
        [self addEnemy];
    }];
    SKAction *sequence = [SKAction sequence:@[wait, addEnemy]];
    return [SKAction repeatActionForever:sequence];
}

- (void)addEnemy
{
    Enemy *enemy;
    if (drand48() < 0.25) {
        enemy = [[HomingEnemy alloc] init];
    } else {
        enemy = [[BouncingEnemy alloc] init];
    }
    [self addChild:enemy];
    [enemy setName:@"enemy"];
    [enemy setPlayer:self.player];
    
    CGFloat magnitude = 0;
    while (magnitude < (enemy.radius + self.player.radius) * 3) {
        [enemy setPosition:CGPointMake(drand48() * self.frame.size.width,
                                       drand48() * self.frame.size.height)];
        
        CGVector distance = CGVectorMake(enemy.position.x - self.player.position.x,
                                         enemy.position.y - self.player.position.y);
        magnitude = sqrt(distance.dx * distance.dx + distance.dy * distance.dy);
    }
    [enemy runAction:[SKAction repeatActionForever:enemy.mainAction]];
}

- (SKAction *)shootBulletsAction
{
    SKAction *wait = [SKAction waitForDuration:0.45];
    SKAction *shootBullet = [SKAction runBlock:^{
        [self fireBulletWithSpeed:150.0 angle: M_PI * -0.04];
        [self fireBulletWithSpeed:150.0 angle: M_PI *  0.04];
        [self fireBulletWithSpeed:150.0 angle: M_PI *  0.0];
    }];
    SKAction *sequence = [SKAction sequence:@[wait, shootBullet]];
    return [SKAction repeatActionForever:sequence];
}

- (void)fireBulletWithSpeed:(CGFloat)speed angle:(CGFloat)angle
{
    CGVector distance = CGVectorMake(self.crosshair.position.x - self.player.position.x,
                                     self.crosshair.position.y - self.player.position.y);
    if (distance.dx == 0 && distance.dy == 0) { distance.dx = 1; }
    
    distance.dx = distance.dx * cos(angle) - distance.dy * sin(angle);
    distance.dy = distance.dx * sin(angle) + distance.dy * cos(angle);
    CGFloat magnitude = sqrt(distance.dx * distance.dx + distance.dy * distance.dy);
    CGVector direction = CGVectorMake(distance.dx / magnitude, distance.dy / magnitude);
    
    CGFloat radius = 1.0;
    SKShapeNode *bullet = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    [bullet setName:@"bullet"];
    [bullet setStrokeColor:[UIColor whiteColor]];
    [bullet setFillColor:[UIColor whiteColor]];
    [self addChild:bullet];
    [bullet setZPosition:-1];
    [bullet setPosition:CGPointMake(self.player.position.x + direction.dx * self.player.radius - radius,
                                    self.player.position.y + direction.dy * self.player.radius - radius)];
    [bullet runAction:[SKAction repeatActionForever:[SKAction moveByX:direction.dx * 1000
                                                                    y:direction.dy * 1000
                                                             duration:1000.0 / speed]]];
}

- (void)didApplyConstraints
{
    [self enumerateChildNodesWithName:@"bullet" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x < -10 ||
            node.position.y < -10 ||
            node.position.x > self.frame.size.width + 10 ||
            node.position.y > self.frame.size.height + 10) {
            [node removeFromParent];
        }
    }];
}

- (void)update:(CFTimeInterval)currentTime
{
    [self moveCrosshair];
    SKAction *remove = [SKAction sequence:@[
                                            [SKAction scaleTo:0 duration:0.1],
                                            [SKAction removeFromParent]
                                            ]];
    
    [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
        Enemy *enemy = (Enemy *)node;
        if ([enemy actionForKey:@"remove"] == nil) {
            [self enumerateChildNodesWithName:@"bullet" usingBlock:^(SKNode *node, BOOL *stop) {
                if ([node actionForKey:@"remove"] == nil) {
                    CGVector distance = CGVectorMake(enemy.position.x - node.position.x,
                                                     enemy.position.y - node.position.y);
                    CGFloat magnitude = sqrt(distance.dx * distance.dx + distance.dy * distance.dy);
                    if (magnitude < enemy.radius) {
                        [enemy runAction:remove withKey:@"remove"];
                        [node runAction:remove withKey:@"remove"];
                        *stop = YES;
                    }
                }
            }];
            
            SKNode *node = self.player;
            if ([node actionForKey:@"remove"] == nil) {
                CGVector distance = CGVectorMake(enemy.position.x - node.position.x,
                                                 enemy.position.y - node.position.y);
                CGFloat magnitude = sqrt(distance.dx * distance.dx + distance.dy * distance.dy);
                if (magnitude < enemy.radius) {
                    [enemy runAction:remove withKey:@"remove"];
                    [node runAction:remove withKey:@"remove"];
                }
            }
        }
    }];
}

- (void)moveCrosshair
{
    CGVector distance = CGVectorMake(self.crosshair.position.x - self.player.position.x,
                                     self.crosshair.position.y - self.player.position.y);
    CGFloat magnitude = sqrt(distance.dx * distance.dx + distance.dy * distance.dy);
    CGFloat maxDistance = 20;
    
    if (magnitude > maxDistance && magnitude != 0) {
        CGVector vector = CGVectorMake((distance.dx / magnitude) * maxDistance,
                                       (distance.dy / magnitude) * maxDistance);
        
        CGPoint position = CGPointMake(self.player.position.x + vector.dx,
                                       self.player.position.y + vector.dy);
        SKAction *move = [SKAction moveTo:position duration:0.01];
        [self.crosshair runAction:move];
    }
}

#pragma mark - Touches


/*
 - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 for (UITouch *touch in touches) {
 CGPoint location = [touch locationInNode:self];
 [self.player setPosition:location];
 }
 }
 */

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.crosshair == nil) {
        [self setupCrosshair];
        [self runAction:self.shootBulletsAction withKey:@"shoot"];
        [self runAction:self.addEnemiesAction withKey:@"addEnemies"];
    }
    
    CGVector distance = CGVectorMake(0, 0);
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        distance.dx += location.x - previousLocation.x;
        distance.dy += location.y - previousLocation.y;
    }
    
    CGFloat magnitude = sqrt(distance.dx * distance.dx + distance.dy * distance.dy);
    CGVector direction = CGVectorMake(distance.dx / magnitude, distance.dy / magnitude);
    CGFloat power = MIN(magnitude, 30);
    CGVector movement = CGVectorMake(direction.dx * power * (10 + power) * 0.07,
                                     direction.dy * power * (10 + power) * 0.07);
    SKAction *move = [SKAction moveBy:movement duration:0.15];
    [self.player runAction:move];
}

@end
