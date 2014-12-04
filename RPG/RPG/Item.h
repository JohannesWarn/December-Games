//
//  Item.h
//  RPG
//
//  Created by Johannes Wärn on 04/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Actor;

@interface Item : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic, copy) NSString *(^itemBlock)(Item *item, Actor *user, Actor *otherActor);

+ (instancetype)itemWithName:(NSString *)name;

@end

@interface Potion : Item
@end