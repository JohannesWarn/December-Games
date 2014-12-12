//
//  Tile.m
//  Tower Tap
//
//  Created by Johannes Wärn on 12/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Tile.h"

@implementation Tile

+ (instancetype)tileOfKind:(int)kind withSize:(CGSize)size
{
    Tile *tile = [Tile shapeNodeWithRectOfSize:size];
    [tile setKind:kind];
    if (kind == 0) {
        [tile setFillColor:nil];
    } else {
        [tile setFillColor:[UIColor colorWithHue:0.6 saturation:0.5 brightness:0.1 alpha:1.0]];
    }
    [tile setStrokeColor:nil];
    
    return tile;
}

@end
