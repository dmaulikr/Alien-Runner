//
//  TPButton.h
//  Tappy Plane
//
//  Created by J Hastwell on 7/05/2014.
//  Copyright (c) 2014 Code Coalition. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SoundManager.h"

@interface TPButton : SKSpriteNode

@property (nonatomic, readonly, weak) id pressedTarget;
@property (nonatomic, readonly) SEL pressedAction;
@property (nonatomic) CGFloat pressedScale;
@property (nonatomic) Sound *pressedSound;

-(void)setPressedTarget:(id)pressedTarget withAction:(SEL)pressedAction;

+(instancetype)spriteNodeWithTexture:(SKTexture *)texture;

@end
