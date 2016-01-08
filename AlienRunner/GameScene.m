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

@interface GameScene ()

@property (nonatomic) JSTileMap *map;
@property (nonatomic) TMXLayer *mainLayer;
@property (nonatomic) SKNode *cameraTest;
@property (nonatomic) Player *player;

@end

@implementation GameScene

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.81 green:0.91 blue:0.96 alpha:1.0];
        
        // Load level.
        self.map = [JSTileMap mapNamed:@"Level1.tmx"];
        self.mainLayer = [self.map layerNamed:@"Main"];
        [self addChild:self.map];
        
        // Setup camera.
        //self.cameraTest = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(5, 5)];
        self.cameraTest = [SKNode node];
        self.cameraTest.position = CGPointMake(size.width * 0.5, size.height * 0.5);
        [self.map addChild:self.cameraTest];
        
        // Setup Player.
        self.player = [[Player alloc] init];
        //[self.player setScale:0.7];
        self.player.position = [self getMarkerPosition:@"Player"];
        
        [self.map addChild:self.player];
        
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    for (UITouch *touch in touches) {
//        CGPoint touchLocation = [touch locationInNode:self];
//        if (touchLocation.x < 50) {
//            self.player.velocity = CGVectorMake(-5, self.player.velocity.dy);
//        } else if (touchLocation.x > self.size.width - 50) {
//            self.player.velocity = CGVectorMake(5, self.player.velocity.dy);
//        } else {
//            self.player.position = [touch locationInNode:self.map];
//            self.player.velocity = CGVectorMake(0, 0);
//        }
//    }
     self.player.didJump = YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    for (UITouch *touch in touches) {
//        CGPoint touchLocation = [touch locationInNode:self];
//        CGPoint previousTouchLocation = [touch previousLocationInNode:self];
//        CGPoint movement = CGPointMake(touchLocation.x - previousTouchLocation.x,
//                                       touchLocation.y - previousTouchLocation.y);
//       // self.cameraTest.position = CGPointMake(self.cameraTest.position.x - movement.x, self.cameraTest.position.y - movement.y);
//        self.player.position = CGPointMake(self.player.position.x + movement.x, self.player.position.y + movement.y);
//        [self updateView];
//    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.player.didJump = NO;
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.player.didJump = NO;
}

-(void)collide:(Player*)player withLayer:(TMXLayer*)layer
{
    // Create coordinate offsets for tiles to check.
    CGPoint coodOffsets[8] = {CGPointMake(0, 1), CGPointMake(0, -1), CGPointMake(1, 0), CGPointMake(-1, 0),
        CGPointMake(1, -1), CGPointMake(-1, -1), CGPointMake(1, 1), CGPointMake(-1, 1)};
    // Get tile grid coord for player's position.
    CGPoint playerCoord = [layer coordForPoint:player.targetPosition];
    
    // Set on ground to no by default
    player.onGround = NO;
    
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
                // Do we move the player horizontally or vertically?
                BOOL resolveVertically = offset.x == 0 || (offset.y != 0 && intersection.size.height < intersection.size.width);
                CGPoint positionAdjustment = CGPointZero;
                
                if (resolveVertically) {
                    // Calculate the distance we need to move the player.
                    positionAdjustment.y = intersection.size.height * offset.y;
                    // Stop player moving vertically.
                    player.velocity = CGVectorMake(player.velocity.dx, 0);
                    
                    if (offset.y == 1) {
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
            }
        }
    }
    
    
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
    
    // Collide player with world.
    [self collide:self.player withLayer:self.mainLayer];
    
    // Move player.
    self.player.position = self.player.targetPosition;
    
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
    // Center view on camera's position in the map.
    self.map.position = CGPointMake((self.size.width * 0.5) - x, (self.size.height * 0.5) - y);
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
@end
