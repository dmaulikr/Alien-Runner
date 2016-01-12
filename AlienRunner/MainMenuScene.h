//
//  MainMenuScene.h
//  AlienRunner
//
//  Created by Simeon Andreev on 1/11/16.
//  Copyright © 2016 Simeon Andreev. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum : NSUInteger {
    Home,
    LevelFailed,
    LevelCompleted
} MenuMode;

@interface MainMenuScene : SKScene

@property (nonatomic) MenuMode mode;

@end
