//
//  OKNoise.h
//  White
//
//  Created by Christian Gratton on 2013-04-04.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKNoise : NSObject

@property int perlin_octaves;
@property int perlin_amp_falloff;
@property int perlin_TWOPI;
@property int perlin_PI;
@property (nonatomic) float *perlin_cosTable;
@property (nonatomic) float *perlin;

/* PApplet */

+ (OKNoise*) defaultGenerator;

+ (float) noiseX:(float)x;

+ (float) noiseX:(float)x y:(float)y;

+ (float) noiseX:(float)x y:(float)y z:(float)z;

+ (float) noise_fsc:(float)i;

+ (void) noiseDetail:(float)lod;

+ (void) noiseDetail:(float)lod falloff:(float)falloff;

/* PGraphics */

+ (float*) cosLUT;

/* Random */

- (float) floatRandom;

@end
