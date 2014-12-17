//
//  Unit.m
//  RTS
//
//  Created by Johannes Wärn on 17/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Unit.h"

@implementation Unit

+ (instancetype)unit
{
    return nil;
}

- (NSArray *)commands
{
    return nil;
}

@end

@implementation Peasant

+ (Unit *)unit
{
    CGFloat radius = 22;
    Peasant *peasant = [Peasant shapeNodeWithCircleOfRadius:radius];
    [peasant setName:@"unit"];
    [peasant setFillColor:[SKColor colorWithHue:0.5 saturation:0.7 brightness:0.8 alpha:1.0]];
    
    [peasant setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:radius]];
    [peasant.physicsBody setAllowsRotation:NO];
    [peasant.physicsBody setLinearDamping:25.0];
    
    /*
    SKFieldNode *fieldNode = [SKFieldNode radialGravityField];
    [peasant addChild:fieldNode];
    [fieldNode setCategoryBitMask:uniqueId];
//    [fieldNode setMinimumRadius:22.0];
//    [fieldNode setFalloff:5.0];
    [fieldNode setStrength:-0.02];
     */
    
    return peasant;
}

- (NSArray *)commands
{
    return @[[MoveUnit command]];
}

@end