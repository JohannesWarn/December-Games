//
//  Field.h
//  Tetris Attack
//
//  Created by Johannes Wärn on 01/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class Tile;

@interface Field : SKNode

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;
@property (nonatomic, readonly) CGSize tileSize;

@property (nonatomic) int rows;

- (instancetype)initWithWidth:(int)width height:(int)height tileSize:(CGSize)tileSize;

- (Tile *)tileAtX:(int)x y:(int)y;
- (void)addBottomRow;
- (void)swapTileAtX:(int)x1 y:(int)y2 withTileAtX:(int)x2 y:(int)y2;
- (void)applyGravity;
- (void)removeMatches;

@end
