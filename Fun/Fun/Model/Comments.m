//
//  Comments.m
//  Fun
//
//  Created by administration on 13-3-22.
//  Copyright (c) 2013年 administration. All rights reserved.
//

#import "Comments.h"

@implementation Comments

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.funID = [dictionary objectForKey:@"id"];
        
        id user = [dictionary objectForKey:@"user"];
        if ((NSNull *)user != [NSNull null]) {
            NSDictionary * user = [NSDictionary dictionaryWithDictionary:[dictionary objectForKey:@"user"]];
            self.reviewer = [user objectForKey:@"login"];
        }
        
        self.content = [dictionary objectForKey:@"content"];
        self.floor = [[dictionary objectForKey:@"floor"]intValue];
    }
    return self;
}

- (void)dealloc
{
    self.funID = nil;
    self.reviewer = nil;
    self.content = nil;
    [super dealloc];
}

@end
