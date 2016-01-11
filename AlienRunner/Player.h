//
//  Player.h
//  AlienRunner
//
//  Created by Simeon Andreev on 1/8/16.
//  Copyright © 2016 Simeon Andreev. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum : NSUInteger {
    Running,
    Jumping,
    Hurt,
} PlayerState;

@interface Player : SKSpriteNode

@property (nonatomic) CGVector velocity;
@property (nonatomic) CGPoint targetPosition;
@property (nonatomic) BOOL didJump;
@property (nonatomic) BOOL onGround;
@property (nonatomic) CGFloat gravityMultiplier;
@property (nonatomic) PlayerState state;

-(void)update;
-(CGRect)collisionRectAtTarget;
-(BOOL)gravityFlipped;
-(void)kill;

@end
