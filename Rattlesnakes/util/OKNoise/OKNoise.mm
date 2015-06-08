//
//  OKNoise.m
//  White
//
//  Created by Christian Gratton on 2013-04-04.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKNoise.h"

/* PApplet */

#define DEG_TO_RAD 3.1415926f / 180.0f
#define PERLIN_YWRAPB 4
#define PERLIN_YWRAP 1<<PERLIN_YWRAPB
#define PERLIN_ZWRAPB 8
#define PERLIN_ZWRAP 1<<PERLIN_ZWRAPB
#define PERLIN_SIZE 4095

/* PGraphics */

#define SINCOS_PRECISION 0.5f
#define SINCOS_LENGTH (int)(360.0f / SINCOS_PRECISION)

/* Random */

#define ARC4RANDOM_MAX 0x100000000

static OKNoise *defaultGenerator;

@implementation OKNoise
@synthesize perlin_octaves, perlin_amp_falloff, perlin_TWOPI, perlin_PI, perlin_cosTable, perlin;

#pragma mark - PApplet

+ (OKNoise*) defaultGenerator {
    
    @synchronized(self) {
        if(defaultGenerator == nil) {
            defaultGenerator = [[OKNoise alloc] init];
            
            defaultGenerator.perlin = new float[PERLIN_SIZE + 1];
            
            for(int i = 0; i < (PERLIN_SIZE + 1); i++) {
                defaultGenerator.perlin[i] = [defaultGenerator floatRandom];
            }
            
            float *cosLut = [OKNoise cosLUT];
            defaultGenerator.perlin_cosTable = new float[SINCOS_LENGTH];
            memcpy(defaultGenerator.perlin_cosTable, cosLut, SINCOS_LENGTH * sizeof(float));
            
            defaultGenerator.perlin_TWOPI = defaultGenerator.perlin_PI = SINCOS_LENGTH;
            defaultGenerator.perlin_PI >>= 1;
            
            defaultGenerator.perlin_octaves = 4;
            defaultGenerator.perlin_amp_falloff = 0.5f;
        }
    }
    return defaultGenerator;
    
}

+ (float) noiseX:(float)x {
    return [OKNoise noiseX:x y:0.0f z:0.0f];
}

+ (float) noiseX:(float)x y:(float)y {
    return [OKNoise noiseX:x y:y z:0.0f];
}

+ (float) noiseX:(float)x y:(float)y z:(float)z {
    OKNoise *generator = [OKNoise defaultGenerator];
    
    if (x<0) x=-x;
    if (y<0) y=-y;
    if (z<0) z=-z;
    
    int xi=(int)x, yi=(int)y, zi=(int)z;
    float xf = (float)(x-xi);
    float yf = (float)(y-yi);
    float zf = (float)(z-zi);
    float rxf, ryf;
    
    float r=0;
    float ampl=0.5f;
    
    float n1,n2,n3;
    
    for(int i = 0; i < generator.perlin_octaves; i++) {
        int of=xi+(yi<<PERLIN_YWRAPB)+(zi<<PERLIN_ZWRAPB);
        
        rxf=[OKNoise noise_fsc:xf];
        ryf=[OKNoise noise_fsc:yf];
        
        n1  = generator.perlin[of&PERLIN_SIZE];
        n1 += rxf*(generator.perlin[(of+1)&PERLIN_SIZE]-n1);
        n2  = generator.perlin[(of+PERLIN_YWRAP)&PERLIN_SIZE];
        n2 += rxf*(generator.perlin[(of+PERLIN_YWRAP+1)&PERLIN_SIZE]-n2);
        n1 += ryf*(n2-n1);
        
        of += PERLIN_ZWRAP;
        n2  = generator.perlin[of&PERLIN_SIZE];
        n2 += rxf*(generator.perlin[(of+1)&PERLIN_SIZE]-n2);
        n3  = generator.perlin[(of+PERLIN_YWRAP)&PERLIN_SIZE];
        n3 += rxf*(generator.perlin[(of+PERLIN_YWRAP+1)&PERLIN_SIZE]-n3);
        n2 += ryf*(n3-n2);
        
        n1 += [OKNoise noise_fsc:zf]*(n2-n1);
        
        r += n1*ampl;
        ampl *= generator.perlin_amp_falloff;
        xi<<=1; xf*=2;
        yi<<=1; yf*=2;
        zi<<=1; zf*=2;
        
        if (xf>=1.0f) { xi++; xf--; }
        if (yf>=1.0f) { yi++; yf--; }
        if (zf>=1.0f) { zi++; zf--; }
    }
    return r;
}

+ (float) noise_fsc:(float)i {
    OKNoise *generator = [OKNoise defaultGenerator];
    
    return 0.5f * (1.0f - generator.perlin_cosTable[(int)(i * generator.perlin_PI) % generator.perlin_TWOPI]);
}

+ (void) noiseDetail:(float)lod {
    OKNoise *generator = [OKNoise defaultGenerator];
    
    [generator setPerlin_octaves:lod];
}

+ (void) noiseDetail:(float)lod falloff:(float)falloff {
    OKNoise *generator = [OKNoise defaultGenerator];
    
    [generator setPerlin_octaves:lod];
    [generator setPerlin_amp_falloff:falloff];
}

#pragma mark - PGraphics

+ (float*) cosLUT {
    
    float *cosLUT = new float[SINCOS_LENGTH];
    
    for(int i = 0; i < SINCOS_LENGTH; i++) {
        cosLUT[i] = sinf(i * DEG_TO_RAD * SINCOS_PRECISION);
    }
    
    return cosLUT;
}

#pragma mark - Random

- (float) floatRandom { return (float)arc4random()/ARC4RANDOM_MAX; }

@end

