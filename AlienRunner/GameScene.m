//
//  GameScene.m
//  AlienRunner
//
//  Created by Simeon Andreev on 1/8/16.
//  Copyright (c) 2016 Simeon Andreev. All rights reserved.
//

#import "GameScene.h"
#import "JSTileMap.h"
#import "Player.h"
#import "MainMenuScene.h"
#import "Constants.h"

@interface GameScene ()

@property (nonatomic) JSTileMap *map;
@property (nonatomic) TMXLayer *mainLayer;
@property (nonatomic) SKNode *cameraTest;
@property (nonatomic) Player *player;
@property (nonatomic) TMXLayer *obstacleLayer;
@property (nonatomic) TMXLayer *backgroundLayer;

@end

@implementation GameScene

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.81 green:0.91 blue:0.96 alpha:1.0];
        
        // Get selected level.
        NSInteger selectedLevel = [[NSUserDefaults standardUserDefaults] integerForKey:kARSelectedLevel];
        NSString *levelName = [NSString stringWithFormat:@"Level%d.tmx", (int)selectedLevel];
        
        // Load level.
        self.map = [JSTileMap mapNamed:levelName];
        self.mainLayer = [self.map layerNamed:@"Main"];
        self.obstacleLayer = [self.map layerNamed:@"Obstacles"];
        self.backgroundLayer = [self.map layerNamed:@"Background"];
        [self addChild:self.map];
        
        // Setup camera.
        self.cameraTest = [SKNode node];
        self.cameraTest.position = CGPointMake(size.width * 0.5, size.height * 0.5);
        [self.map addChild:self.cameraTest];
        
        // Setup Player.
        self.player = [[Player alloc] init];
        self.player.position = [self getMarkerPosition:@"Player"];
        
        [self.map addChild:self.player];
        
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
}

-(void)touchStateChanged:(CGPoint)location buttonState:(BOOL)state
{
    if (location.x < 150) {
        self.player.moveLeft = state;
    } else if (location.x < 300) {
        self.player.moveRight = state;
    } else {
        self.player.didJump = state;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInNode:self];
        [self touchStateChanged:touchLocation buttonState:YES];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint prevTouchLocation = [touch  previousLocationInNode:self];
        [self touchStateChanged:prevTouchLocation buttonState:NO];
        CGPoint touchLocation = [touch locationInNode:self];
        [self touchStateChanged:touchLocation buttonState:YES];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInNode:self];
        [self touchStateChanged:touchLocation buttonState:NO];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInNode:self];
        [self touchStateChanged:touchLocation buttonState:NO];
    }
}


-(BOOL)collide:(Player*)player withLayer:(TMXLayer*)layer resolveWithMove:(BOOL)movePlayer
{
    // Create coordinate offsets for tiles to check.
    CGPoint coodOffsets[8] = {CGPointMake(0, 1), CGPointMake(0, -1), CGPointMake(1, 0), CGPointMake(-1, 0),
        CGPointMake(1, -1), CGPointMake(-1, -1), CGPointMake(1, 1), CGPointMake(-1, 1)};
    // Get tile grid coord for player's position.
    CGPoint playerCoord = [layer coordForPoint:player.targetPosition];
    BOOL collision = NO;
    
    if (movePlayer) {
        // Set on ground to no by default
        player.onGround = NO;
    }
    
    // Loop through the tiles surrounding tile at player's location
    for (int i = 0; i < 8; i++) {
        // Get player's collision rectangle.
        CGRect playerRect = [player collisionRectAtTarget];
        // Get tile coordinate for offset grid location.
        CGPoint offset = coodOffsets[i];
        CGPoint tileCoord = CGPointMake(playerCoord.x + offset.x, playerCoord.y + offset.y);
        
        // Get gid for tile at coordinate.
        int gid = 0;
        if ([self validTileCoord:tileCoord]) {
            gid = [layer.layerInfo tileGidAtCoord:tileCoord];
        }
        
        if (gid != 0) {
            CGRect intersection = CGRectIntersection(playerRect, [self rectForTileCoord:tileCoord]);
            
            if (!CGRectIsEmpty(intersection)) {
                // We have a collision
                collision = YES;
                if (movePlayer) {
                    // Do we move the player horizontally or vertically?
                // Do we move the player horizontally or vertically?
                BOOL resolveVertically = offset.x == 0 || (offset.y != 0 && intersection.size.height < intersection.size.width);
                CGPoint positionAdjustment = CGPointZero;
                
                if (resolveVertically) {
                    // Calculate the distance we need to move the player.
                    positionAdjustment.y = intersection.size.height * offset.y;
                    // Stop player moving vertically.
                    player.velocity = CGVectorMake(player.velocity.dx, 0);
                    
                    if (offset.y == player.gravityMultiplier) {
                        // Player is touching the ground.
                        player.onGround = YES;
                    }
                    
                } else {
                    // Calculate the distance we need to move the player.
                    positionAdjustment.x = intersection.size.width * -offset.x;
                    // Stop player moving horizontally.
                    player.velocity = CGVectorMake(0, player.velocity.dy);
                }
                player.targetPosition = CGPointMake(player.targetPosition.x + positionAdjustment.x,
                                                    player.targetPosition.y + positionAdjustment.y);
                } else {
                    // We've encountered a collision but don't need to move, so no point continuing.
                    return YES;
                }
            }
        }
    }
    
    return collision;
}

-(BOOL)validTileCoord:(CGPoint)tileCoord
{
    return tileCoord.x >= 0
    && tileCoord.y >= 0
    && tileCoord.x < self.map.mapSize.width
    && tileCoord.y < self.map.mapSize.height;
}

-(CGRect)rectForTileCoord:(CGPoint)tileCoord
{
    CGFloat x = tileCoord.x * self.map.tileSize.width;
    CGFloat mapHeight = self.map.mapSize.height * self.map.tileSize.height;
    CGFloat y = mapHeight - ((tileCoord.y + 1) * self.map.tileSize.height);
    return CGRectMake(x, y, self.map.tileSize.width, self.map.tileSize.height);
}

-(void)update:(NSTimeInterval)currentTime
{
    // Update player.
    [self.player update];
    
    // Check if the player has fallen out of the world.
    if (self.player.targetPosition.y < -self.player.size.height * 2 ||
        self.player.targetPosition.y > (self.map.mapSize.height * self.map.tileSize.height) + self.player.size.height * 2) {
        // Fallen outside the world.
        [self gameOver:NO];
    } else {
        if (self.player.state != Hurt) {
            // Collide player with world.
            [self collide:self.player withLayer:self.mainLayer resolveWithMove:YES];
            // Collide with obstacles.
            BOOL collision = [self collide:self.player withLayer:self.obstacleLayer resolveWithMove:NO];
            if (collision) {
                [self.player kill];
            }
        }
        // Move player.
        self.player.position = self.player.targetPosition;
        
        // Check if the player has completed the level.
        if (self.player.position.x - self.player.size.width > self.map.mapSize.width * self.map.tileSize.width) {
            // Reached end of the level.
            [self gameOver:YES];
        }
    }
    
    // Update position of camera.
    self.cameraTest.position = CGPointMake(self.player.position.x + (self.size.width * 0.25), self.player.position.y);
    [self updateView];
}

-(void)updateView
{
    // Calculate clamped x and y locations.
    CGFloat x = fmaxf(self.cameraTest.position.x, self.size.width * 0.5);
    CGFloat y = fmaxf(self.cameraTest.position.y, self.size.height * 0.5);
    x = fminf(x, (self.map.mapSize.width * self.map.tileSize.width) - self.size.width * 0.5);
    y = fminf(y, (self.map.mapSize.height * self.map.tileSize.height) - self.size.height * 0.5);
    
    // Align x and y to pixel grid.
    x = roundf(x * 2) / 2;
    y = roundf(y * 2) / 2;
    
    // Center view on camera's position in the map.
    self.map.position = CGPointMake((self.size.width * 0.5) - x, (self.size.height * 0.5) - y);
    
    // Parallax scroll the background layer.
    self.backgroundLayer.position = CGPointMake(self.map.position.x * -0.2, self.map.position.y * -0.2);
}

-(CGPoint)getMarkerPosition:(NSString*)markerName
{
    CGPoint position;
    TMXObjectGroup *markerLayer = [self.map groupNamed:@"Markers"];
    if (markerLayer) {
        NSDictionary *marker = [markerLayer objectNamed:markerName];
        if (marker) {
            position = CGPointMake([[marker valueForKey:@"x"] floatValue],
                                   [[marker valueForKey:@"y"] floatValue]);
        }
    }
    return position;
}

-(void)gameOver:(BOOL)completedLevel
{
    if (completedLevel) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger selectedLevel = [userDefaults integerForKey:kARSelectedLevel];
        NSInteger highestUnlockedLevel = [userDefaults integerForKey:kARHighestUnlockedLevel];
        if (selectedLevel == highestUnlockedLevel && kARHighestLevel > highestUnlockedLevel) {
            highestUnlockedLevel++;
            [userDefaults setInteger:highestUnlockedLevel forKey:kARHighestUnlockedLevel];
        }
        if (selectedLevel < highestUnlockedLevel) {
            selectedLevel++;
            [userDefaults setInteger:selectedLevel forKey:kARSelectedLevel];
        }
        [userDefaults synchronize];
    }
    MainMenuScene *mainMenu = [[MainMenuScene alloc] initWithSize:self.size];
    if (completedLevel) {
        mainMenu.mode = LevelCompleted;
    } else {
        mainMenu.mode = LevelFailed;
    }
    [self.view presentScene:mainMenu];
}

@end
