//
//  Enemy.h
//  Turn 2
//
//  Created by Johannes Wärn on 09/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Enemy : SKShapeNode

@property (nonatomic) CGFloat radius;
@property (nonatomic) int kind;

- (void)updateColor;

@end
