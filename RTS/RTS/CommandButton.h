//
//  CommandButton.h
//  RTS
//
//  Created by Johannes Wärn on 17/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class Command;

@interface CommandButton : SKShapeNode

@property (nonatomic) Command *command;

@end
