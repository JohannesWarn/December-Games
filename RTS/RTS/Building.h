//
//  Building.h
//  RTS
//
//  Created by Johannes Wärn on 17/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import "Unit.h"

@interface Building : Unit

@property (nonatomic) CGFloat radius;

@end

@interface TownHall : Building
@end