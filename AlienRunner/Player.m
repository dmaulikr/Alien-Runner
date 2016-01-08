//
//  Player.m
//  AlienRunner
//
//  Created by Simeon Andreev on 1/8/16.
//  Copyright © 2016 Simeon Andreev. All rights reserved.
//

#import "Player.h"

static const CGFloat kGravity = -0.2;
static const BOOL kShowCollisionRect = YES;
static const CGFloat kAcceleration = 0.15;
static const CGFloat kMaxSpeed = 5;
static const CGFloat kJumpSpeed = 5.5;
static const CGFloat kJumpCutOffSpeed = 2.5;

@interface Player()

@property (nonatomic) BOOL didJumpPrevious;

@end

@implementation Player

- (instancetype)init
{
    self = [super initWithImageNamed:@"p1_walk01"];
    if (self) {
        
    }
    return self;
}

-(void)update
{
    if (kShowCollisionRect) {
        [self removeAllChildren];
        SKShapeNode *box = [SKShapeNode node];
        box.path = CGPathCreateWithRect([self collisionRectAtTarget], nil);
        box.strokeColor = [SKColor redColor];
        box.lineWidth = 0.1;
        box.position = CGPointMake(-self.targetPosition.x, -self.targetPosition.y);
        [self addChild:box];
    }
    
    // Apply gravity.
    self.velocity = CGVectorMake(self.velocity.dx, self.velocity.dy + kGravity);
   
    // Apply acceleration.
   // self.velocity = CGVectorMake(fminf(kMaxSpeed, self.velocity.dx + kAcceleration), self.velocity.dy);
    
    if (self.didJump && !self.didJumpPrevious) {
        // Starting a jump.
        if (self.onGround) {
            // Perform jump.
            self.velocity = CGVectorMake(self.velocity.dx, kJumpSpeed);
        }
    } else if(!self.didJump) {
        // Cancel jump.
        if (self.velocity.dy > kJumpCutOffSpeed) {
            self.velocity = CGVectorMake(self.velocity.dx, kJumpCutOffSpeed);
        }
    }
    
    // Move player.
    //self.position = CGPointMake(self.position.x + self.velocity.dx, self.position.y + self.velocity.dy);
    
    self.targetPosition = CGPointMake(self.position.x + self.velocity.dx, self.position.y + self.velocity.dy);
    
    // Track previous jump state.
    self.didJumpPrevious = self.didJump;
}

-(CGRect)collisionRectAtTarget
{
    // Calculate smaller rectanlge based on frame.
    CGRect collisionRect = CGRectInset(self.frame, 4, 2);
    // Move rectangle to target position
    CGPoint movement = CGPointMake(self.targetPosition.x - self.position.x, self.targetPosition.y - self.position.y);
    collisionRect = CGRectOffset(collisionRect, movement.x, movement.y - 2);
    return collisionRect;
}

@end
