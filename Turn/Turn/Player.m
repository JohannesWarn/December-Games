//
//  Player.m
//  Turn
//
//  Created by Johannes Wärn on 09/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Player.h"

@implementation Player

- (instancetype)init
{
    if (self = [super init]) {
        self.radius = 20;
        self.path = CGPathCreateWithEllipseInRect(CGRectMake(-self.radius, -self.radius, self.radius * 2, self.radius * 2), nil);
        self.kind = 0;
        self.direction = kLeft;
        [self updateColor];
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.radius];
        self.physicsBody.restitution = 1.0;
        self.physicsBody.friction = 0.0;
        self.physicsBody.linearDamping = 50.0;
        
        self.physicsBody.categoryBitMask = 1 << 0;
        self.physicsBody.contactTestBitMask = 1 << 1;
    }
    
    return self;
}

- (void)updateColor
{
    self.fillColor = [self colorForKind:self.kind];
}

- (UIColor *)colorForKind:(int)kind
{
    return [UIColor colorWithHue:(1.0 / 3.0) * kind saturation:0.76 brightness:0.78 alpha:1.0];
}

@end
