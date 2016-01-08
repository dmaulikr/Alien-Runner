//
//  Player.h
//  AlienRunner
//
//  Created by Simeon Andreev on 1/8/16.
//  Copyright © 2016 Simeon Andreev. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Player : SKSpriteNode

@property (nonatomic) CGVector velocity;
@property (nonatomic) CGPoint targetPosition;
@property (nonatomic) BOOL didJump;
@property (nonatomic) BOOL onGround;

-(void)update;
-(CGRect)collisionRectAtTarget;

@end
