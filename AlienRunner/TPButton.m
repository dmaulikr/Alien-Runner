//
//  TPButton.m
//  Tappy Plane
//
//  Created by J Hastwell on 7/05/2014.
//  Copyright (c) 2014 Code Coalition. All rights reserved.
//

#import "TPButton.h"
#import <objc/message.h>

@interface TPButton()

@property (nonatomic) CGRect fullSizeFrame;
@property (nonatomic) BOOL pressed;

@end

@implementation TPButton

+(instancetype)spriteNodeWithTexture:(SKTexture *)texture
{
    return [TPButton spriteNodeWithTexture:texture andDisabledTexture:nil];
}

+(instancetype)spriteNodeWithTexture:(SKTexture *)texture andDisabledTexture:(SKTexture*)disabledTexture
{
    TPButton *instance = [super spriteNodeWithTexture:texture];
    instance.enabledTexture = texture;
    instance.disabledTexture = disabledTexture;
    instance.pressedScale = 0.9;
    instance.userInteractionEnabled = YES;
    return instance;
}

-(void)setPressedTarget:(id)pressedTarget withAction:(SEL)pressedAction
{
    _pressedTarget = pressedTarget;
    _pressedAction = pressedAction;
}

-(void)setDisabled:(BOOL)disabled
{
    if (_disabled != disabled) {
        _disabled = disabled;
        if (_disabled ) {
            self.texture = self.disabledTexture;
        } else {
            self.texture = self.disabledTexture;
        }
        self.userInteractionEnabled = !_disabled;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.fullSizeFrame = self.frame;
    [self touchesMoved:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (self.pressed != CGRectContainsPoint(self.fullSizeFrame, [touch locationInNode:self.parent])) {
            self.pressed = !self.pressed;
            if (self.pressed) {
                [self setScale:self.pressedScale];
                [self.pressedSound play];
            } else {
                [self setScale:1.0];
            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setScale:1.0];
    self.pressed = NO;
    for (UITouch *touch in touches) {
        if (CGRectContainsPoint(self.fullSizeFrame, [touch locationInNode:self.parent])) {
            // Pressed button.
            ((void(*)(id, SEL))objc_msgSend)(self.pressedTarget, self.pressedAction);
            if (self.delegate) {
                [self.delegate buttonPressed:self];
            }
        }
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setScale:1.0];
    self.pressed = NO;
}

@end
