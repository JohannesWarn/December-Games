//
//  Building.m
//  RTS
//
//  Created by Johannes Wärn on 17/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Building.h"

@implementation Building

@end

@implementation TownHall

+ (instancetype)unit
{
    CGFloat radius = 30;
    TownHall *townHall = [TownHall shapeNodeWithCircleOfRadius:radius];
    [townHall setFillColor:[SKColor colorWithHue:0.4 saturation:0.3 brightness:0.7 alpha:1.0]];
    
    [townHall setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:radius]];
    [townHall.physicsBody setDynamic:NO];
    
    return townHall;
}

- (NSArray *)commands
{
    return @[[CreatePeasant command]];
}

@end