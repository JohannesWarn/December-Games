//
//  Cursor.m
//  Tetris Attack
//
//  Created by Johannes Wärn on 01/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Cursor.h"

@interface Cursor ()

@property (nonatomic) CGSize tileSize;
@property (nonatomic) CGFloat rowWidth;

@property (nonatomic) SKSpriteNode *rowNode;
@property (nonatomic) SKSpriteNode *sourceNode;
@property (nonatomic) SKSpriteNode *destinationNode;

@end

@implementation Cursor

+ (instancetype)cursorWithTileSize:(CGSize)tileSize rowWidth:(CGFloat)rowWidth
{
    Cursor *cursor = [self node];
    if (cursor) {
        [cursor setTileSize:tileSize];
        [cursor setRowWidth:rowWidth];
        
        UIColor *rowColor = [UIColor colorWithWhite:0.0 alpha:0.1];
        [cursor setRowNode:[SKSpriteNode spriteNodeWithColor:rowColor size:CGSizeMake(rowWidth, tileSize.height)]];
        
        UIColor *sourceColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        [cursor setSourceNode:[SKSpriteNode spriteNodeWithColor:sourceColor size:tileSize]];
        
        UIColor *destinationColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        [cursor setDestinationNode:[SKSpriteNode spriteNodeWithColor:destinationColor size:tileSize]];
        
        [cursor addChild:cursor.rowNode];
        [cursor addChild:cursor.sourceNode];
        [cursor addChild:cursor.destinationNode];
        
        [cursor.rowNode setPosition:CGPointMake(rowWidth * 0.5, 0)];
    }
    return cursor;
}

- (void)moveTo:(int)y
{
    _y = y;
}

- (void)moveSourceTo:(int)x
{
    _sourceX = x;
    
    CGPoint position = CGPointMake((x + 0.5) * self.tileSize.width, 0);
    [self.sourceNode setPosition:position];
}

- (void)moveDestinationTo:(int)x
{
    _destinationX = x;
    
    CGPoint position = CGPointMake((x + 0.5) * self.tileSize.width, 0);
    [self.destinationNode setPosition:position];
}

@end
