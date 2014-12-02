//
//  Tile.m
//  Tetris Attack
//
//  Created by Johannes Wärn on 01/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <tgmath.h>

#import "Tile.h"

@implementation Tile

+ (int)possibleKinds
{
    return 6;
}

+ (UIColor *)colorForKind:(int)kind
{
    CGFloat hue = fmod(0.0 + (CGFloat)kind / (CGFloat)[self possibleKinds], 1.0);
    return [UIColor colorWithHue:hue saturation:0.69 brightness:0.81 alpha:1];
}

+ (instancetype)tileWithSize:(CGSize)size
{
    int kind = arc4random() % [self possibleKinds];
    return [self tileWithKind:kind size:size];
}

+ (instancetype)tileWithKind:(int)kind size:(CGSize)size
{
    UIColor *color = [self colorForKind:kind];
    Tile *tile = [self spriteNodeWithColor:color size:size];
    if (tile) {
        [tile setKind: kind];
    }
    return tile;
}

@end
