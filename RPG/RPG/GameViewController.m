//
//  GameViewController.m
//  RPG
//
//  Created by Johannes Wärn on 04/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "GameViewController.h"
#import "Player.h"
#import "Enemy.h"
#import "Attack.h"
#import "Item.h"

@interface GameViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) Player *player;
@property (nonatomic) Enemy *enemy;

@property (weak, nonatomic) IBOutlet UITextView *playerTextView;
@property (weak, nonatomic) IBOutlet UITextView *enemyTextView;

@property (weak, nonatomic) IBOutlet UITableView *attacksDrawer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attacksDrawerShownConstraint;
@property (weak, nonatomic) IBOutlet UITableView *itemsDrawer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemsDrawerShownConstraint;

@property (weak, nonatomic) IBOutlet UIButton *attackButton;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.player = [[Player alloc] init];
    self.enemy = [self randomEnemy];
    [self updateText];
    
    [[self attacksDrawerShownConstraint] setPriority:UILayoutPriorityDefaultLow];
    [[self itemsDrawerShownConstraint] setPriority:UILayoutPriorityDefaultLow];
}

- (Enemy *)randomEnemy
{
    if (arc4random() % 4 == 0) {
        return [[Bear alloc] init];
    } else {
        return [[Bat alloc] init];
    }
}

- (void)updateText
{
    [self.playerTextView setText:[self.player debugString]];
    [self.enemyTextView setText:[self.enemy debugString]];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)hideAttackDrawer
{
    [[self attacksDrawerShownConstraint] setPriority:UILayoutPriorityDefaultLow];
}

- (void)showAttackDrawer
{
    [[self attacksDrawerShownConstraint] setPriority:UILayoutPriorityDefaultHigh];
}

- (void)hideItemsDrawer
{
    [[self itemsDrawerShownConstraint] setPriority:UILayoutPriorityDefaultLow];
}

- (void)showItemsDrawer
{
    [[self itemsDrawerShownConstraint] setPriority:UILayoutPriorityDefaultHigh];
}

- (void)animateDrawersAfterDelay:(NSTimeInterval)delay
{
    [UIView animateWithDuration:0.55
                          delay:delay
         usingSpringWithDamping:0.9
          initialSpringVelocity:1.0
                        options:0
                     animations:^{ [self.view layoutIfNeeded]; }
                     completion:nil];
}

- (IBAction)toggleAttackDrawer:(UIButton *)sender {
    if (self.attacksDrawerShownConstraint.priority < UILayoutPriorityDefaultHigh) {
        [self showAttackDrawer];
    } else {
        [self hideAttackDrawer];
    }
    [self hideItemsDrawer];
    [self animateDrawersAfterDelay:0.0];}

- (IBAction)toggleItemsDrawer:(UIButton *)sender {
    if (self.itemsDrawerShownConstraint.priority < UILayoutPriorityDefaultHigh) {
        [self showItemsDrawer];
    } else {
        [self hideItemsDrawer];
    }
    [self hideAttackDrawer];
    [self animateDrawersAfterDelay:0.0];
}

- (IBAction)escape:(UIButton *)sender {
    if (arc4random() % 3 < 1) {
        [self.player.history insertObject:@"Unable to escape." atIndex:0];
        [self.enemy performAttack:[self.enemy attackAgainstActor:self.player] againstActor:self.player];
    } else {
        [self.player.history insertObject:@"Escaped from enemy." atIndex:0];
        self.enemy = [self randomEnemy];
    }
    
    [self updateText];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.attacksDrawer]) {
        return self.player.attacks.count;
    } else if ([tableView isEqual:self.itemsDrawer]) {
        return self.player.items.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([tableView isEqual:self.attacksDrawer]) {
        cell =  [tableView dequeueReusableCellWithIdentifier:@"row" forIndexPath:indexPath];
        Attack *attack = [self.player.attacks objectAtIndex:indexPath.row];
        [[cell textLabel] setText:attack.name];
    } else if ([tableView isEqual:self.itemsDrawer]) {
        cell =  [tableView dequeueReusableCellWithIdentifier:@"row" forIndexPath:indexPath];
        Item *item = [self.player.items objectAtIndex:indexPath.row];
        [[cell textLabel] setText:item.name];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.attackButton.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([tableView isEqual:self.attacksDrawer]) {
        Attack *attack = [self.player.attacks objectAtIndex:indexPath.row];
        if ([self.player performAttack:attack againstActor:self.enemy]) {
            if (self.enemy.health <= 0) {
                [self.player defeatedEnemy:self.enemy];
                self.enemy = [self randomEnemy];
            } else {
                if (![self.enemy performAttack:[self.enemy attackAgainstActor:self.player] againstActor:self.player]) {
                    [self.enemy.history insertObject:@"Did nothing. Duh." atIndex:0];
                }
                if (self.player.health <= 0) {
                    self.player = [[Player alloc] init];
                    [self.player.history addObject:@"Died. Respawned. Sadface."];
                    self.enemy = [self randomEnemy];
                }
            }
            [self hideAttackDrawer];
            [self animateDrawersAfterDelay:0.05];
        }
    } else if ([tableView isEqual:self.itemsDrawer]) {
        Item *item = [self.player.items objectAtIndex:indexPath.row];
        if ([self.player useItem:item againstActor:self.enemy]) {
            if (self.enemy.health <= 0) {
                [self.player defeatedEnemy:self.enemy];
                self.enemy = [self randomEnemy];
            } else {
                if (![self.enemy performAttack:[self.enemy attackAgainstActor:self.player] againstActor:self.player]) {
                    [self.enemy.history insertObject:@"Did nothing. Duh." atIndex:0];
                }
                if (self.player.health <= 0) {
                    self.player = [[Player alloc] init];
                    [self.player.history addObject:@"Died. Respawned. Sadface."];
                    self.enemy = [self randomEnemy];
                }
            }
            [self hideItemsDrawer];
            [self animateDrawersAfterDelay:0.05];
        }
    }
    
    [self updateText];
    [self.itemsDrawer reloadData];
    
    [tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

@end
