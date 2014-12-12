//
//  Tile.h
//  Tower Tap
//
//  Created by Johannes Wärn on 12/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Tile : SKShapeNode

@property (nonatomic) int kind;

+ (instancetype)tileOfKind:(int)kind withSize:(CGSize)size;

@end
