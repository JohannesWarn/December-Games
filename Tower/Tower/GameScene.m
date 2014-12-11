//
//  GameScene.m
//  Tower
//
//  Created by Johannes Wärn on 11/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameScene.h"
#import "Player.h"

@interface GameScene ()

@property (nonatomic) SKNode *baseNode;
@property (nonatomic) Player *player;

@property (nonatomic) NSTimeInterval lastTime;
@property (nonatomic) UITouch *currentTouch;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    [self setupWorld];
    [self setupPlayer];
}

- (void)setupWorld
{
    self.baseNode = [SKNode node];
    [self addChild:self.baseNode];
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    for (int i = 0; i < 4; i ++) {
        CGSize size = CGSizeMake(100 * i + arc4random() % 20,
                                 30 + arc4random() % 20);
        
        SKShapeNode *box = [Player shapeNodeWithRectOfSize:size];
        box.fillColor = [SKColor colorWithHue:0.6 saturation:0.8 brightness:0.8 alpha:1.0];
        
        box.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        box.physicsBody.allowsRotation = NO;
        box.physicsBody.linearDamping = 6.0;
        
        [self.baseNode addChild:box];
        
        box.position = CGPointMake(100, 100);
    }
    
    self.physicsWorld.gravity = CGVectorMake(0, -20);
}

- (void)setupPlayer
{
    CGSize size = CGSizeMake(floor(self.size.width * 0.1),
                             floor(self.size.width * 0.1));
    self.player = [Player playerWithSize:size];
    self.player.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
    
    [self.baseNode addChild:self.player];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.currentTouch == nil) {
        self.currentTouch = [touches anyObject];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.currentTouch == nil) {
        self.currentTouch = [touches anyObject];
    }
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        if (location.y > previousLocation.y + 5) {
            if (self.player.physicsBody.allContactedBodies.count != 0) {
                CGVector force = CGVectorMake(0, 4000);
                [self.player.physicsBody applyForce:force];
                
                return;
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches containsObject:self.currentTouch]) {
        self.currentTouch = nil;
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    NSTimeInterval timeDelta = (currentTime - self.lastTime);
    self.lastTime = currentTime;
    if (self.lastTime == 0) { return; }
    
    if (self.currentTouch) {
        CGPoint touchLocation = [self.currentTouch locationInNode:self];
        
        CGFloat halfWidth = self.size.width / 2;
        CGFloat relativeLocation = (touchLocation.x - halfWidth) / halfWidth;
        CGFloat direction = MAX(MIN(6.0 * pow(relativeLocation, 3), 1.0), -1.0);
        
        CGVector force = CGVectorMake(6000 * timeDelta * direction, 0);
        [self.player.physicsBody applyForce:force];
    }
    
//    self.baseNode.position = CGPointMake(0, -(self.player.position.y - (self.size.height / 2)));
}

@end
