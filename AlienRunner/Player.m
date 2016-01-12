//
//  Player.m
//  AlienRunner
//
//  Created by Simeon Andreev on 1/8/16.
//  Copyright © 2016 Simeon Andreev. All rights reserved.
//

#import "Player.h"

static const CGFloat kGravity = -0.24;
static const BOOL kShowCollisionRect = NO;
static const CGFloat kAcceleration = 0.07;
static const CGFloat kMaxSpeed = 3.5;
static const CGFloat kJumpSpeed = 9.5;
static const CGFloat kJumpCutOffSpeed = 3.5;

@interface Player()

@property (nonatomic) BOOL didJumpPrevious;
@property (nonatomic) BOOL canFlipGravity;
@property (nonatomic) SKAction *runningAnimation;

@end

@implementation Player

- (instancetype)init
{
    self = [super initWithImageNamed:@"p1_walk01"];
    if (self) {
        // Create array for frames for run animation.
        NSMutableArray *walkFrames = [NSMutableArray array];
        for (int i = 1; i < 12; i++) {
            SKTexture *frame = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"p1_walk%02d", i]];
            [walkFrames addObject:frame];
        }
        
        // Create action for run animation.
        SKAction *animation = [SKAction animateWithTextures:walkFrames timePerFrame:(1.0/15.0) resize:NO restore:NO];
        self.runningAnimation = [SKAction repeatActionForever:animation];
        
        [self runAction:self.runningAnimation withKey:@"Run"];
        
        // Set gravity to pull down by default.
        self.gravityMultiplier = 1;
    }
    return self;
}

-(BOOL)gravityFlipped
{
    return self.gravityMultiplier == -1;
}

-(void)setState:(PlayerState)state
{
    if (_state != state) {
        if (_state == Running) {
            [self removeActionForKey:@"Run"];
        }
        // Update instance variable.
        _state = state;
        switch (state) {
            case Running:
                [self runAction:self.runningAnimation withKey:@"Run"];
                break;
            case Jumping:
                self.texture = [SKTexture textureWithImageNamed:@"p1_jump"];
                break;
            case Hurt:
                self.texture = [SKTexture textureWithImageNamed:@"p1_hurt"];
                break;
            default:
                break;
        }
    }
}

-(void)setGravityMultiplier:(CGFloat)gravityMultiplier
{
    _gravityMultiplier = gravityMultiplier;
    // Set the texture orientation to match the pull of gravity.
    self.yScale = gravityMultiplier;
}

-(void)update
{
    if (kShowCollisionRect) {
        [self removeAllChildren];
        SKShapeNode *box = [SKShapeNode node];
        CGRect rect = [self collisionRectAtTarget];
        if (self.gravityFlipped) {
            rect.origin.y -= 4;
        }
        box.path = CGPathCreateWithRect(rect, nil);
        box.path = CGPathCreateWithRect([self collisionRectAtTarget], nil);
        box.strokeColor = [SKColor redColor];
        box.lineWidth = 0.1;
        box.position = CGPointMake(-self.targetPosition.x, -self.targetPosition.y);
        [self addChild:box];
    }
    
    // Apply gravity.
    self.velocity = CGVectorMake(self.velocity.dx, self.velocity.dy + kGravity * self.gravityMultiplier);
   
    if (self.state != Hurt) {
        
        // Apply acceleration.
        //self.velocity = CGVectorMake(fminf(kMaxSpeed, self.velocity.dx + kAcceleration), self.velocity.dy);
        
        // Apply acceleration.
        if (self.moveRight) {
             self.xScale = 1;
            self.velocity = CGVectorMake(fminf(kMaxSpeed, self.velocity.dx + kAcceleration), self.velocity.dy);
        } else if(self.velocity.dx > 0) {
            self.velocity = CGVectorMake(fmaxf(0, self.velocity.dx - (kAcceleration * 2)), self.velocity.dy);
        }
        if (self.moveLeft) {
             self.xScale = -1;
            self.velocity = CGVectorMake(fmaxf(-kMaxSpeed, self.velocity.dx - kAcceleration), self.velocity.dy);
        } else if (self.velocity.dx < 0) {
            self.velocity = CGVectorMake(fminf(0, self.velocity.dx + (kAcceleration * 2)), self.velocity.dy);
        }
        if (self.state == Running) {
            if (self.velocity.dx == 0) {
                [self actionForKey:@"Run"].speed = 0;
            } else {
                [self actionForKey:@"Run"].speed = 1;
            }
        }
        // Prevent ability to flip gravity when player lands on the ground.
        if (self.onGround) {
            self.canFlipGravity = NO;
            self.state = Running;
        } else {
            self.state = Jumping;
        }
        
        if (self.didJump && !self.didJumpPrevious) {
            // Starting a jump.
            if (self.onGround) {
                // Perform jump.
                self.velocity = CGVectorMake(self.velocity.dx, kJumpSpeed * self.gravityMultiplier);
                // Set ability to flip gravity.
                self.canFlipGravity = YES;
            } else if (self.canFlipGravity) {
                
                // Flip gravity.
                //self.gravityMultiplier *= -1;
                
                // Perform jump. ->
                self.velocity = CGVectorMake(self.velocity.dx, kJumpSpeed * self.gravityMultiplier);
                // ->
                
                // Prevent further flips until next jump.
                self.canFlipGravity = NO;
            }
        } else if(!self.didJump) {
            // Cancel jump.
            if (self.gravityFlipped) {
                if (self.velocity.dy < -kJumpCutOffSpeed) {
                    self.velocity = CGVectorMake(self.velocity.dx, -kJumpCutOffSpeed);
                }
            } else {
                if (self.velocity.dy > kJumpCutOffSpeed) {
                    self.velocity = CGVectorMake(self.velocity.dx, kJumpCutOffSpeed);
                }
            }
        }
       
    }
    
    self.targetPosition = CGPointMake(self.position.x + self.velocity.dx, self.position.y + self.velocity.dy);
    
    // Track previous jump state.
    self.didJumpPrevious = self.didJump;
}

-(CGRect)collisionRectAtTarget
{
    // Calculate smaller rectangle.
    CGRect collisionRect = CGRectMake(self.targetPosition.x - (self.size.width * self.anchorPoint.x) + 4,
                                      self.targetPosition.y - (self.size.height * self.anchorPoint.y),
                                      self.size.width - 8, self.size.height - 4);
    if (self.gravityFlipped) {
        // Move rectangle up because the bottom is now at the top in parent coords.
        collisionRect.origin.y += 4;
    }
    return collisionRect;
}

-(void)kill
{
    self.state = Hurt;
    self.velocity = CGVectorMake(0, kJumpSpeed * self.gravityMultiplier);
}


@end
