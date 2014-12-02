//
//  Player.h
//  Space Shooter
//
//  Created by Johannes Wärn on 02/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Player : SKNode

@property (nonatomic, readonly) CGFloat radius;

+ (instancetype)player;

@end
