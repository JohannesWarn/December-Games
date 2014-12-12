//
//  GameScene.m
//  Tower Tap
//
//  Created by Johannes Wärn on 12/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameScene.h"
#import "Player.h"
#import "Level.h"
#import "Tile.h"

@interface GameScene ()

@property (nonatomic) CGSize tileSize;
@property (nonatomic) SKNode *rootNode;
@property (nonatomic) Level *currentLevel;
@property (nonatomic) Player *player;

@property (nonatomic) int levelWidth;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view
{
    typeof(self) __weak weakSelf = self;
    
    [self setBackgroundColor:[UIColor colorWithHue:0.55 saturation:0.1 brightness:0.8 alpha:1.0]];
    
    self.levelWidth = 16;
    self.tileSize = CGSizeMake(self.size.width / self.levelWidth, self.size.width / self.levelWidth);
    self.rootNode = [SKNode node];
    [self addChild:self.rootNode];
    
    self.currentLevel = [Level levelWithWidth:self.levelWidth tileSize:self.tileSize];
    [self.currentLevel enumerateTilesWithBlock:^(int x, int y, Tile *tile) {
        [weakSelf.rootNode addChild:tile];
        [tile setPosition:CGPointMake((x + 0.5) * weakSelf.tileSize.width,
                                      (y + 0.5) * weakSelf.tileSize.height)];
    }];
    
    [self setupPlayer];
}

- (void)setupPlayer
{
    self.player = [Player playerWithSize:CGSizeMake(self.tileSize.width, self.tileSize.height)];
    [self.player setPosition:CGPointMake(4.0 * self.tileSize.width + self.player.size.width / 2,
                                         4.0 * self.tileSize.height + self.player.size.height / 2)];
    [self.rootNode addChild:self.player];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGVector velocity = self.player.velocity;
    velocity.dy = 0.37 * self.tileSize.height;
    self.player.velocity = velocity;
}

- (void)update:(CFTimeInterval)currentTime
{
    [self updatePlayer:self.player];
}

- (void)updatePlayer:(Player *)player
{
    // Make mutable copies of velocity and position
    CGVector velocity = player.velocity;
    CGPoint position = player.position;
    
    // Calculate the x acceleration
    CGFloat acceleration = 0.005 * self.tileSize.width;
    if (player.direction == DirectionLeft) {
        acceleration *= -1;
    } else if (player.direction == DirectionNone) {
        acceleration *= 0;
    }
    
    // Apply acceleration and friction
    velocity.dx += acceleration;
    velocity.dx *= 0.9;
    
    // Apply gravity and friction
    velocity.dy -= 0.015 * self.tileSize.height;
    velocity.dy *= 0.98;
    
    // Calculate where the player will be in the future
    CGPoint top    = CGPointMake(position.x + velocity.dx, position.y + player.size.height / 2 - 1);
    CGPoint bottom = CGPointMake(position.x + velocity.dx, position.y - player.size.height / 2 + 1);
    if (player.direction == DirectionRight) {
        top.x    += player.size.width / 2;
        bottom.x += player.size.width / 2;
    } else {
        top.x    -= player.size.width / 2;
        bottom.x -= player.size.width / 2;
    }
    
    // Check for future collisions on the x-axis
    if (position.x + velocity.dx < player.size.width / 2 ||
        position.x + velocity.dx > self.size.width - player.size.width / 2 ||
        [[self.currentLevel tileAt:top] kind] == 1 ||
        [[self.currentLevel tileAt:bottom] kind] == 1) {
        // If there is a collision on the x-axis move the player to the wall and change the direction
        if (self.player.direction == DirectionLeft) {
            self.player.direction = DirectionRight;
            position.x = round(position.x / self.tileSize.width) * self.tileSize.width - player.size.width / 2;
            velocity.dx = ABS(velocity.dx);
        } else if (self.player.direction == DirectionRight) {
            self.player.direction = DirectionLeft;
            position.x = round(position.x / self.tileSize.width) * self.tileSize.width + player.size.width / 2;
            velocity.dx = -ABS(velocity.dx);
        }
    } else {
        // If there are no collisions mutate the position
        position.x += velocity.dx;
    }
    
    
    CGPoint leftTop     = CGPointMake(position.x - player.size.width / 2 + 1, position.y + velocity.dy + player.size.height / 2);
    CGPoint rightTop    = CGPointMake(position.x + player.size.width / 2 - 1, position.y + velocity.dy + player.size.height / 2);
    CGPoint leftBottom  = CGPointMake(position.x - player.size.width / 2 + 1, position.y + velocity.dy - player.size.height / 2);
    CGPoint rightBottom = CGPointMake(position.x + player.size.width / 2 - 1, position.y + velocity.dy - player.size.height / 2);
    
    // Check for future collisions on the y-axis
    if ([[self.currentLevel tileAt:leftBottom] kind] == 1 ||
        [[self.currentLevel tileAt:rightBottom] kind] == 1) {
        // The player fell onto the ground
        position.y = round(position.y / self.tileSize.height) * self.tileSize.height - player.size.height / 2;
        velocity.dy = 0;
    } else if ([[self.currentLevel tileAt:leftTop] kind] == 1 ||
               [[self.currentLevel tileAt:rightTop] kind] == 1) {
        // The player jumped into the ceiling
        position.y = round(position.y / self.tileSize.height) * self.tileSize.height + player.size.height / 2;
        velocity.dy = 0;
    } else {
        // If there are no collisions mutate the position
        position.y += velocity.dy;
    }
    
//    position.y += velocity.dy;
    
    // Update the actual values
    player.velocity = velocity;
    player.position = position;
}

@end
