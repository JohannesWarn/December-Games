//
//  Enemy.h
//  Space Shooter
//
//  Created by Johannes Wärn on 02/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Enemy : SKNode

@property (nonatomic) CGFloat radius;
@property (nonatomic) SKShapeNode *body;
@property (nonatomic) SKNode *player;

- (SKAction *)mainAction;

@end
