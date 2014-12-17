//
//  GameScene.m
//  RTS
//
//  Created by Johannes Wärn on 17/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameScene.h"

#import "Unit.h"
#import "Building.h"
#import "Command.h"
#import "CommandButton.h"

@interface GameScene ()

@property (nonatomic) SKNode *worldNode;
@property (nonatomic) SKNode *cameraNode;
@property (nonatomic) SKNode *menu;

@property (nonatomic) Unit *selectedUnit;
@property (nonatomic) Command *selectedCommand;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view
{
    [self setupWorld];
    [self setupBase];
    [self setupMenu];
    
    [self setupUGestureRecognizer];
}

- (void)setupUGestureRecognizer
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [[self view] addGestureRecognizer:tapRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [[self view] addGestureRecognizer:pinchRecognizer];
}

- (void)setupMenu
{
    _menu = [SKNode node];
    [self addChild:_menu];
    [_menu setPosition:CGPointMake(-self.size.width / 2, -self.size.height / 2)];
}

- (void)setupWorld
{
    self.anchorPoint = CGPointMake (0.5,0.5);
    
    [self.physicsWorld setGravity:CGVectorMake(0.0, 0.0)];
    
    _worldNode = [SKNode node];
    [self addChild:_worldNode];
    
    [self setupCamera];
}

- (void)setupCamera
{
    _cameraNode = [SKNode node];
    _cameraNode.name = @"camera";
    [_worldNode addChild:_cameraNode];
}

- (void)setupBase
{
    TownHall *townHall = [TownHall unit];
    Peasant *peasant = [Peasant unit];
    
    [townHall setPosition:CGPointMake( 120.0,  10.0)];
    [peasant  setPosition:CGPointMake(-30.0, -20.0)];
    peasant.target = peasant.position;
    
    [_worldNode addChild:townHall];
    [_worldNode addChild:peasant];
}

- (void)selectUnit:(Unit *)unit
{
    _selectedUnit = unit;
    _selectedCommand = nil;
    [self updateMenu];
}

- (void)selectCommandButton:(CommandButton *)commandButton withUnit:(Unit *)unit
{
    if ([commandButton.command isEqual:_selectedCommand]) {
        [self selectCommandButton:nil withUnit:nil];
        return;
    }
    
    for (CommandButton *button in [_menu children]) {
        [button setStrokeColor:[SKColor whiteColor]];
        [button setLineWidth:1.0];
    }
    
    Command *command = commandButton.command;
    
    if ([command isKindOfClass:[CreatePeasant class]]) {
        Peasant *peasant = [Peasant unit];
        [_worldNode addChild:peasant];
        CGPoint position = unit.position;
        CGFloat ang = drand48() * M_PI * 2;
        position.x += cos(ang) * 50;
        position.y += sin(ang) * 50;
        peasant.position = position;
        peasant.target = peasant.position;
    } else {
        _selectedCommand = command;
        [commandButton setStrokeColor:[SKColor redColor]];
        [commandButton setLineWidth:3.0];
    }
}

- (void)runCommand:(Command *)command withUnit:(Unit *)unit point:(CGPoint)point
{
    CGPoint location = [_worldNode convertPoint:point fromNode:self];
    [unit setTarget:location];
}

- (void)updateMenu
{
    [_menu removeAllChildren];
    if (_selectedUnit != nil) {
        int i = 0;
        for (Command *command in [_selectedUnit commands]) {
            CommandButton *button = [CommandButton shapeNodeWithCircleOfRadius:40];
            [button setCommand:command];
            [_menu addChild:button];
            [button setFillColor:[SKColor whiteColor]];
            [button setPosition:CGPointMake(50, 90 * i + 50)];
            
            SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Bold"];
            [button addChild:label];
            [label setText:command.title];
            [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
            [label setFontSize:11];
            [label setFontColor:[SKColor blackColor]];
            
            i++;
        }
    }
}

- (Unit *)unitAtPoint:(CGPoint)point
{
    NSArray *nodes = [self nodesAtPoint:point];
    for (SKNode *node in nodes) {
        if ([node isKindOfClass:[Unit class]]) {
            return (Unit *)node;
        }
    }
    return nil;
}

- (CommandButton *)commandButtonAtPoint:(CGPoint)point
{
    NSArray *nodes = [self nodesAtPoint:point];
    for (SKNode *node in nodes) {
        if ([node isKindOfClass:[CommandButton class]]) {
            return (CommandButton *)node;
        }
    }
    return nil;
}

- (void)moveUnit:(Unit *)unit
{
    CGVector vector = CGVectorMake(unit.target.x - unit.position.x, unit.target.y - unit.position.y);
    CGFloat distance = vector.dx * vector.dx + vector.dy * vector.dy;
    if (distance > 0.01) {
        distance = sqrt(distance);
        CGVector normal = CGVectorMake(vector.dx / distance, vector.dy / distance);
        CGVector impulse = CGVectorMake(normal.dx * 3.0,
                                        normal.dy * 3.0);
        if (distance < 50) {
            impulse.dx *= distance / 50;
            impulse.dy *= distance / 50;
        }
        [unit.physicsBody applyImpulse:impulse];
    }
}

#pragma mark - Touches

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint location = [self convertPointFromView:[sender locationInView:sender.view]];
    
    Unit *unit = [self unitAtPoint:location];
    CommandButton *commandButton = [self commandButtonAtPoint:location];
    
    if (commandButton) {
        [self selectCommandButton:commandButton withUnit:_selectedUnit];
    } else if (_selectedCommand) {
        [self runCommand:_selectedCommand withUnit:_selectedUnit point:location];
    } else {
        [self selectUnit:unit];
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)sender
{
    [_worldNode setScale:sender.scale];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:_worldNode];
        CGPoint previousLocation = [touch previousLocationInNode:_worldNode];
        CGVector locationDelta = CGVectorMake(location.x - previousLocation.x,
                                              location.y - previousLocation.y);
        [_cameraNode runAction:[SKAction moveBy:CGVectorMake(-locationDelta.dx, -locationDelta.dy) duration:0.0]];
    }
}

#pragma mark - SpriteKit Event Loop

-(void)update:(CFTimeInterval)currentTime
{
    [_worldNode enumerateChildNodesWithName:@"unit" usingBlock:^(SKNode *node, BOOL *stop) {
        if ([node isKindOfClass:[Unit class]]) {
            Unit *unit = (Unit *)node;
            [self moveUnit:unit];
        }
    }];
}

- (void)didFinishUpdate
{
    [self centerOnNode:_cameraNode];
}

- (void) centerOnNode:(SKNode *)node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x,
                                       node.parent.position.y - cameraPositionInScene.y);
}

@end
