//
//  Field.m
//  Tetris Attack
//
//  Created by Johannes Wärn on 01/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Field.h"
#include "Tile.h"

@interface Field ()

@property (nonatomic) NSMutableArray *tiles;
@property (nonatomic) BOOL shouldApplyGravity;
@property (nonatomic) BOOL shouldRemoveMatches;

@end

@implementation Field

- (instancetype)initWithWidth:(int)width height:(int)height tileSize:(CGSize)tileSize
{
    if (self = [super init]) {
        _width = width;
        _height = height;
        _tileSize = tileSize;
        _tiles = [self randomTiles];
        _shouldApplyGravity = NO;
        _rows = 0;
        [self addTileNodes];
    }
    return self;
}

- (NSMutableArray *)randomTiles
{
    NSMutableArray *tiles = [NSMutableArray array];
    NSMutableArray *previousRow = nil;
    for (int i = 0; i < _height; i++) {
        NSMutableArray *row = [NSMutableArray array];
        for (int j = 0; j < _width; j++) {
            if (arc4random() % (self.width * 9) <= i * i || [[previousRow objectAtIndex:j] isKindOfClass:[NSNull class]]) {
                [row addObject:[NSNull null]];
            } else {
                Tile *tile = [Tile tileWithSize:self.tileSize];
                [row addObject:tile];
            }
        }
        [tiles addObject:row];
        previousRow = row;
    }
    return tiles;
}

- (void)enumarateTiles:(NSMutableArray *)tiles withBlock:(void (^)(Tile *, int, int))block
{
    for (int i = 0; i < _height; i++) {
        NSMutableArray *row = [tiles objectAtIndex:i];
        for (int j = 0; j < _width; j++) {
            if ([[row objectAtIndex:j] isKindOfClass:[Tile class]]) {
                Tile *tile = [row objectAtIndex:j];
                block(tile, j, i);
            }
        }
    }
}

- (void)addBottomRow
{
    _rows++;
    
    [self enumarateTiles:_tiles withBlock:^(Tile *tile, int x, int y){
        CGPoint position = tile.position;
        position.y += self.tileSize.height;
        [tile setPosition:position];
    }];
    [self.tiles removeLastObject];
    
    NSMutableArray *row = [NSMutableArray array];
    for (int j = 0; j < _width; j++) {
        Tile *tile = [Tile tileWithSize:self.tileSize];
        [row addObject:tile];
        
        [self addChild:tile];
        [tile setPosition:CGPointMake((j + 0.5) * self.tileSize.width,
                                      (0 + 0.5) * self.tileSize.height)];
    }
    [self.tiles insertObject:row atIndex:0];
}

- (void)addTileNodes
{
    typeof(self) __weak weakSelf = self;
    [self enumarateTiles:self.tiles withBlock:^(Tile *tile, int x, int y) {
        [weakSelf addChild:tile];
        [tile setPosition:CGPointMake((x + 0.5) * self.tileSize.width,
                                          (y + 0.5) * self.tileSize.height)];
    }];
}

- (Tile *)tileAtX:(int)x y:(int)y
{
    if ([[[_tiles objectAtIndex:y] objectAtIndex:x] isKindOfClass:[Tile class]]) {
        return [[_tiles objectAtIndex:y] objectAtIndex:x];
    }
    return nil;
}

- (void)removeTileAtX:(int)x y:(int)y
{
    Tile *tile = [self tileAtX:x y:y];
    
    NSMutableArray *row = [_tiles objectAtIndex:y];
    [row replaceObjectAtIndex:x withObject:[NSNull null]];
    
    SKAction *scaleOut = [SKAction scaleTo:0.2 duration:0.15];
    [scaleOut setTimingMode:SKActionTimingEaseIn];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.15];
    SKAction *animateOut = [SKAction group:@[scaleOut, fadeOut]];
    
    SKAction *remove = [SKAction runBlock:^{
        [tile removeFromParent];
        _shouldApplyGravity = YES;
    }];
    
    [tile runAction:[SKAction sequence:@[animateOut, remove]] withKey:@"remove"];
}

- (void)swapTileAtX:(int)x1 y:(int)y1 withTileAtX:(int)x2 y:(int)y2
{
    Tile *tile1 = [self tileAtX:x1 y:y1];
    Tile *tile2 = [self tileAtX:x2 y:y2];
    
    NSMutableArray *row;
    row = [_tiles objectAtIndex:y1];
    if (tile2) {
        [row replaceObjectAtIndex:x1 withObject:tile2];
    } else {
        [row replaceObjectAtIndex:x1 withObject:[NSNull null]];
    }
    
    row = [_tiles objectAtIndex:y2];
    if (tile1) {
        [row replaceObjectAtIndex:x2 withObject:tile1];
    } else {
        [row replaceObjectAtIndex:x2 withObject:[NSNull null]];
    }
    
    CGPoint position1 = CGPointMake((x1 + 0.5) * self.tileSize.width,
                                    (y1 + 0.5) * self.tileSize.height);
    CGPoint position2 = CGPointMake((x2 + 0.5) * self.tileSize.width,
                                    (y2 + 0.5) * self.tileSize.height);
    
    SKAction *scaleOut = [SKAction scaleTo:0.4 duration:0.15];
    SKAction *scaleIn = [SKAction scaleTo:1.0 duration:0.15];
    [scaleOut setTimingMode:SKActionTimingEaseIn];
    [scaleIn setTimingMode:SKActionTimingEaseOut];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.15];
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.15];
    SKAction *animateOut = [SKAction group:@[scaleOut, fadeOut]];
    SKAction *animateIn = [SKAction group:@[scaleIn, fadeIn]];
    
    SKAction *swap = [SKAction runBlock:^{
        [tile1 setPosition:position2];
        [tile2 setPosition:position1];
    }];
    
    SKAction *remove = [SKAction runBlock:^{
        _shouldRemoveMatches = YES;
        _shouldApplyGravity = YES;
    }];

    [tile1 runAction:[SKAction sequence:@[animateOut, swap, animateIn, remove]] withKey:@"swap"];
    if (tile1) {
        [tile2 runAction:[SKAction sequence:@[animateOut, animateIn]] withKey:@"swap"];
    } else {
        [tile2 runAction:[SKAction sequence:@[animateOut, swap, animateIn, remove]] withKey:@"swap"];
    }
}

- (void)applyGravity
{
    if (!_shouldApplyGravity) { return; }
    _shouldApplyGravity = NO;
    
    for (int j = 0; j < _width; j++) {
        BOOL hasGap = NO;
        for (int i = 0; i < _height; i++) {
            Tile *tile = [self tileAtX:j y:i];
            if (tile == nil) {
                hasGap = YES;
            } else if (hasGap) {
                int k = i - 1;
                while (k >= 0 && [self tileAtX:j y:k] == nil) {
                    k--;
                }
                k ++;
                
                SKAction *fall = [SKAction moveToY:(k + 0.5) * self.tileSize.height duration:(i - k) * 0.1];
                SKAction *completion = [SKAction runBlock:^{
                    _shouldRemoveMatches = YES;
                }];
                
                [tile runAction:[SKAction sequence:@[fall, completion]]];
                [[_tiles objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNull null]];
                [[_tiles objectAtIndex:k] replaceObjectAtIndex:j withObject:tile];
            }
        }
    }
}

- (void)removeMatches
{
    if (!_shouldRemoveMatches) { return; }
    _shouldRemoveMatches = NO;
    
    NSMutableArray *positionsToRemove = [NSMutableArray array];
    
    for (int i = 0; i < _height; i++) {
        int currentKind = -1;
        int matches = 0;
        for (int j = 0; j < _width; j++) {
            Tile *tile = [self tileAtX:j y:i];
            if (tile && tile.kind == currentKind && ![tile hasActions]) {
                matches++;
            } else {
                if (matches >= 3) {
                    for (int k = j - 1; k >= j - matches; k--) {
                        [positionsToRemove addObject:@[@(k), @(i)]];
                    }
                }
                if (![tile hasActions]) {
                    matches = 1;
                } else {
                    matches = 0;
                    currentKind = -1;
                }
            }
            currentKind = tile ? tile.kind : -1;
        }
        if (matches >= 3) {
            for (int k = _width - 1; k >= _width - matches; k--) {
                [positionsToRemove addObject:@[@(k), @(i)]];
            }
        }
    }
    
    for (int j = 0; j < _width; j++) {
        int currentKind = -1;
        int matches = 0;
        for (int i = 0; i < _height; i++) {
            Tile *tile = [self tileAtX:j y:i];
            if (tile && tile.kind == currentKind && ![tile hasActions]) {
                matches++;
            } else {
                if (matches >= 3) {
                    for (int k = i - 1; k >= i - matches; k--) {
                        [positionsToRemove addObject:@[@(j), @(k)]];
                    }
                }
                if (![tile hasActions]) {
                    matches = 1;
                } else {
                    matches = 0;
                    currentKind = -1;
                }
            }
            currentKind = tile ? tile.kind : -1;
        }
        if (matches >= 3) {
            for (int k = _height - 1; k >= _height - matches; k--) {
                [positionsToRemove addObject:@[@(j), @(k)]];
            }
        }
    }
    
    for (NSArray *position in positionsToRemove) {
        [self removeTileAtX:[[position objectAtIndex:0] intValue]
                          y:[[position objectAtIndex:1] intValue]];
    }
}

@end
