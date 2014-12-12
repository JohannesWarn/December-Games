//
//  Level.m
//  Tower Tap
//
//  Created by Johannes Wärn on 12/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Level.h"
#import "Tile.h"

@interface Level ()

@property (nonatomic) int levelWidth;
@property (nonatomic) CGSize tileSize;

@end

@implementation Level

+ (instancetype)levelWithWidth:(int)width tileSize:(CGSize)tileSize
{
    Level *level = [[Level alloc] init];
    
    NSMutableArray *tiles = [NSMutableArray array];
    for (int i = 0; i < 30; i++) {
        NSMutableArray *row = [NSMutableArray array];
        int lastKind = 0;
        for (int j = 0; j < width; j++) {
            int kind = (arc4random() % 10) < (1 + lastKind * 5) ? 1 : 0;
            if (i < 4) {
                kind = 1;
            } else if (i < 6) {
                kind = 0;
            }
            Tile *tile = [Tile tileOfKind:kind withSize:tileSize];
            
            lastKind = kind;
            [row addObject:tile];
        }
        [tiles addObject:row];
    }
    
    [level setTiles:tiles];
    [level setTileSize:tileSize];
    [level setLevelWidth:width];
    
    return level;
}

- (void)enumerateTilesWithBlock:(void (^)(int x, int y, Tile *tile))block
{
    for (int i = 0; i < self.tiles.count; i++) {
        NSArray *row = [self.tiles objectAtIndex:i];
        for (int j = 0; j < row.count; j++) {
            Tile *tile = [row objectAtIndex:j];
            block(j, i, tile);
        }
    }
}

- (Tile *)tileAt:(CGPoint)point
{
    int x = point.x / self.tileSize.width;
    int y = point.y / self.tileSize.width;
    return [self tileAt:x y:y];
}

- (Tile *)tileAt:(int)x y:(int)y
{
    if (x < 0 || y < 0 || x >= self.levelWidth) {
        return nil;
    }
    return [[self.tiles objectAtIndex:y] objectAtIndex:x];
}

@end
