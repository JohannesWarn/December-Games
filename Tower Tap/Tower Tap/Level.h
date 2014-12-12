//
//  Level.h
//  Tower Tap
//
//  Created by Johannes Wärn on 12/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tile;

@interface Level : NSObject

@property (nonatomic) NSMutableArray *tiles;

+ (instancetype)levelWithWidth:(int)width tileSize:(CGSize)tileSize;
- (void)enumerateTilesWithBlock:(void (^)(int x, int y, Tile *tile))block;
- (Tile *)tileAt:(CGPoint)point;
- (Tile *)tileAt:(int)x y:(int)y;

@end
