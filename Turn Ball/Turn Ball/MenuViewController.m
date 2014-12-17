//
//  MenuViewController.m
//  Turn Ball
//
//  Created by Johannes Wärn on 16/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "MenuViewController.h"
#import "GameViewController.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UIButton *twoPlayersButton;
@property (weak, nonatomic) IBOutlet UIButton *threePlayersButton;
@property (weak, nonatomic) IBOutlet UIButton *fourPlayersButton;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GameViewController *gameViewControler = (GameViewController *)segue.destinationViewController;
    if ([sender isEqual:self.twoPlayersButton]) {
        gameViewControler.numberOfPlayers = 2;
    } else if ([sender isEqual:self.threePlayersButton]) {
        gameViewControler.numberOfPlayers = 3;
    } else if ([sender isEqual:self.fourPlayersButton]) {
        gameViewControler.numberOfPlayers = 4;
    }
}

@end
