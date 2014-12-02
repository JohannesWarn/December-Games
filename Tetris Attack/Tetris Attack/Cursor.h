//
//  Cursor.h
//  Tetris Attack
//
//  Created by Johannes Wärn on 01/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Cursor : SKNode

+ (instancetype)cursorWithTileSize:(CGSize)tileSize rowWidth:(CGFloat)rowWidth;

@property (nonatomic) int y;
@property (nonatomic) int sourceX;
@property (nonatomic) int destinationX;

- (void)moveTo:(int)y;
- (void)moveSourceTo:(int)x;
- (void)moveDestinationTo:(int)x;

@end
