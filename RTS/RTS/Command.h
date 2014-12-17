//
//  Command.h
//  RTS
//
//  Created by Johannes Wärn on 17/12/14.
//  Copyright (c) 2014 Johannes Wärn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Command : NSObject

+ (instancetype)command;
- (NSString *)title;

@end

@interface MoveUnit : Command
@end

@interface CreatePeasant : Command
@end
