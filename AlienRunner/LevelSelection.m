//
//  LevelSelection.m
//  AlienRunner
//
//  Created by Simeon Andreev on 1/11/16.
//  Copyright © 2016 Simeon Andreev. All rights reserved.
//

#import "LevelSelection.h"

@implementation LevelSelection

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        // Set background color.
        self.backgroundColor = [SKColor colorWithRed:0.16 green:0.27 blue:0.3 alpha:1.0];
        // Setup title node.
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
        title.text = @"Select Level";
        title.fontColor = [SKColor colorWithRed:0.518 green:0.78 blue:1.0 alpha:1.0];
        title.fontSize = 40;
        title.position = CGPointMake(size.width * 0.5, size.height - 100);
        [self addChild:title];
    }
    return self;
}

@end
