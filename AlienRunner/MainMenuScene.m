//
//  MainMenuScene.m
//  AlienRunner
//
//  Created by Simeon Andreev on 1/11/16.
//  Copyright © 2016 Simeon Andreev. All rights reserved.
//

#import "MainMenuScene.h"
#import "Player.h"
#import "TPButton.h"
#import "GameScene.h"
#import "LevelSelection.h"
#import "Constants.h"

@implementation MainMenuScene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        // Set background color.
        self.backgroundColor = [SKColor colorWithRed:0.16 green:0.27 blue:0.3 alpha:1.0];
        
        // Setup title node.
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
        title.text = @"Alien Runner";
        title.fontColor = [SKColor colorWithRed:0.518 green:0.78 blue:1.0 alpha:1.0];
        title.fontSize = 40;
        title.position = CGPointMake(size.width * 0.5, size.height - 100);
        [self addChild:title];
        
        // Setup alien.
        Player *alien = [[Player alloc] init];
        alien.position = CGPointMake(size.width * 0.5, size.height - 150);
        alien.state = Running;
        [self addChild:alien];
        
        // Create label node to display level.
        NSInteger selectedLevel = [[NSUserDefaults standardUserDefaults] integerForKey:kARSelectedLevel];
        SKLabelNode *levelDisplay = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
        levelDisplay.text = [NSString stringWithFormat:@"Level %d", (int)selectedLevel];
        levelDisplay.fontColor = [SKColor colorWithRed:0.518 green:0.78 blue:1.0 alpha:1.0];
        levelDisplay.fontSize = 15;
        levelDisplay.position = CGPointMake(size.width * 0.5, size.height - 295);
        [self addChild:levelDisplay];
        
        // Create Play button.
        TPButton *playButton = [TPButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"ButtonPlay"]];
        playButton.position = CGPointMake(size.width * 0.5 - 55, 90);
        [playButton setPressedTarget:self withAction:@selector(pressedPlayButton)];
        [self addChild:playButton];
        
        // Create level select button.
        TPButton *levelButton = [TPButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"ButtonLevel"]];
        levelButton.position = CGPointMake(size.width * 0.5 + 55, 90);
        [levelButton setPressedTarget:self withAction:@selector(pressedLevelButton)];
        [self addChild:levelButton];
    }
    return self;
}

-(void)pressedPlayButton
{
    [self.view presentScene:[[GameScene alloc] initWithSize:self.size]];
}

-(void)pressedLevelButton
{
    LevelSelection *levelSelectionScene = [[LevelSelection alloc] initWithSize:self.size];
    [self.view presentScene:levelSelectionScene transition:[SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.6]];
}

@end
