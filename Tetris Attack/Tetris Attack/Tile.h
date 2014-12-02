//
//  Tile.h
//  Tetris Attack
//
//  Created by Johannes Wärn on 01/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Tile : SKSpriteNode

@property (nonatomic) int kind;

+ (int)possibleKinds;
+ (instancetype)tileWithSize:(CGSize)size;
+ (instancetype)tileWithKind:(int)kind size:(CGSize)size;

@end
