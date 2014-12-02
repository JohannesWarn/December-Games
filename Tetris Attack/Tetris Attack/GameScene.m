//
//  GameScene.m
//  Tetris Attack
//
//  Created by Johannes Wärn on 01/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameScene.h"
#import "Field.h"
#import "Tile.h"
#import "Cursor.h"

@interface GameScene ()

@property (nonatomic) Field *field;
@property (nonatomic) Cursor *cursor;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view
{
    int width = 6;
    int height = 12;
    CGFloat tileSideLength = self.frame.size.width / width;
    CGSize tileSize = CGSizeMake(tileSideLength, tileSideLength);
    
    [self setField:[[Field alloc] initWithWidth:width height:height tileSize:tileSize]];
    [self addChild:self.field];
    [self.field setPosition:CGPointMake(0, -tileSize.height)];
    [self.field runAction:[self addRowAction]];
}

- (SKAction *)addRowAction
{
    SKAction *moveUp = [SKAction moveByX:0
                                       y:self.field.tileSize.height
                                duration:MAX(8.0 - self.field.rows * 0.2, 0.5)];
    SKAction *completion = [SKAction runBlock:^{
        [self.field addBottomRow];
        [self.field setPosition:CGPointMake(0, -self.field.tileSize.height)];
        [self.field runAction:[self addRowAction]];
        self.cursor.y++;
    }];
    return [SKAction sequence:@[moveUp, completion]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.cursor == nil) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        int y = (location.y - self.field.position.y) / self.field.tileSize.height;
        int x = location.x / self.field.tileSize.width;
        
        [self setCursor:[Cursor cursorWithTileSize:self.field.tileSize rowWidth:self.frame.size.width]];
        [self addChild:self.cursor];
        
        [self.cursor moveTo:y];
        [self.cursor moveSourceTo:x];
        [self.cursor moveDestinationTo:x];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    int x = location.x / self.field.tileSize.width;
    
    [self.cursor moveDestinationTo:x];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    int y = (location.y - self.field.position.y) / self.field.tileSize.height;
    if (y > self.cursor.y + 1) {
        [self.field addBottomRow];
        CGPoint position = self.field.position;
        [self.field setPosition:position];
    } else if (self.cursor.sourceX != self.cursor.destinationX) {
        [self.field swapTileAtX:self.cursor.sourceX
                              y:self.cursor.y
                    withTileAtX:self.cursor.destinationX
                              y:self.cursor.y];
    }
    
    [self.cursor removeFromParent];
    [self setCursor:nil];;
}

- (void)updatePositionForCursor:(Cursor *)cursor
{
    CGPoint position = cursor.position;
    position.y = (cursor.y + 0.5) * self.field.tileSize.height + self.field.position.y;
    [cursor setPosition:position];
}

- (void)didApplyConstraints
{
    [self updatePositionForCursor:self.cursor];
}

- (void)update:(CFTimeInterval)currentTime
{
    [self.field applyGravity];
    [self.field removeMatches];
}

@end
