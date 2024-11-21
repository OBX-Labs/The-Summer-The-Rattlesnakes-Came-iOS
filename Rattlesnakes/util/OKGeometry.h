/* CoreGraphics - CGGeometry.h
 Copyright (c) 1998-2009 Apple Inc.
 All rights reserved. */

#ifndef OKGEOMETRY_H_
#define OKGEOMETRY_H_

#define M_TWO_PI (M_PI*2.0f)

#include <CoreGraphics/CGBase.h>
#include <CoreFoundation/CFDictionary.h>

/* Points. */

struct OKPoint {
    CGFloat x;
    CGFloat y;
    CGFloat z;
};
typedef struct OKPoint OKPoint;

/* Sizes. */

struct OKSize {
    CGFloat width;
    CGFloat height;
    CGFloat depth;
};
typedef struct OKSize OKSize;

/* Make a point from `(x, y)'. */

CG_INLINE OKPoint OKPointMake(CGFloat x, CGFloat y, CGFloat z);

/* Make a size from `(width, height)'. */

CG_INLINE OKSize OKSizeMake(CGFloat width, CGFloat height, CGFloat depth);

//CG_EXTERN const OKPoint OKPointZero
//CG_AVAILABLE_STARTING(__MAC_10_0, __IPHONE_2_0);

/* Return true if `point1' and `point2' are the same, false otherwise. */

//CG_EXTERN bool OKPointEqualToPoint(OKPoint point1, OKPoint point2)
//CG_AVAILABLE_STARTING(__MAC_10_0, __IPHONE_2_0);

/* Return true if `size1' and `size2' are the same, false otherwise. */
//
//CG_EXTERN bool OKSizeEqualToSize(OKSize size1, OKSize size2)
//CG_AVAILABLE_STARTING(__MAC_10_0, __IPHONE_2_0);


////////////////PROCESSING////////////////


/* Return a copy of this vector */

CG_INLINE OKPoint OKPointSet(OKPoint point1);

/* Return a copy of this vector */

CG_INLINE OKPoint OKPointGet(OKPoint point1);

/* Calculate the magnitude */

CG_EXTERN float OKPointMag(OKPoint point1);

/* Add vector to vector */

CG_INLINE OKPoint OKPointAdd(OKPoint point1, OKPoint point2);

/* Add float to vector */

CG_INLINE OKPoint OKPointAddf(OKPoint point1, float n);

/* Remove vector from vector */

CG_INLINE OKPoint OKPointSub(OKPoint point1, OKPoint point2);

/* Multiply vector by vector */

CG_INLINE OKPoint OKPointMult(OKPoint point1, OKPoint point2);

/* Divide vector by vector */

CG_INLINE OKPoint OKPointDiv(OKPoint point1, OKPoint point2);

/* Multiply vector by float */

CG_INLINE OKPoint OKPointMultf(OKPoint point1, float n);

/* Divide vector by float */

CG_INLINE OKPoint OKPointDivf(OKPoint point1, float n);

/* Distance vector by float */

CG_INLINE float OKPointDist(OKPoint point1, OKPoint point2);

/* Return a CGPoint from OKPoint */

CG_INLINE CGPoint CGPointFromOKPoint(OKPoint point1);

/* Return a OKPoint from CGPoint */

CG_INLINE OKPoint OKPointFromCGPoint(CGPoint point1);

////////////////END////////////////


/*** Definitions of inline functions. ***/

CG_INLINE OKPoint
OKPointMake(CGFloat x, CGFloat y, CGFloat z)
{
    OKPoint p; p.x = x; p.y = y; p.z = z; return p;
}

CG_INLINE OKSize
OKSizeMake(CGFloat width, CGFloat height, CGFloat depth)
{
    OKSize size; size.width = width; size.height = height; size.depth = depth; return size;
}

CG_INLINE bool
__OKPointEqualToPoint(OKPoint point1, OKPoint point2)
{
    return point1.x == point2.x && point1.y == point2.y && point1.z == point2.z;
}
#define OKPointEqualToPoint __OKPointEqualToPoint

CG_INLINE bool
__OKSizeEqualToSize(OKSize size1, OKSize size2)
{
    return size1.width == size2.width && size1.height == size2.height && size1.depth == size2.depth;
}
#define OKSizeEqualToSize __OKSizeEqualToSize

////////////////PROCESSING////////////////

/* Return a copy of this vector */

CG_INLINE OKPoint
OKPointSet(OKPoint point1)
{
    OKPoint p; p.x = point1.x; p.y = point1.y; p.z = point1.z; return p;
}

/* Return a copy of this vector */

CG_INLINE OKPoint
OKPointGet(OKPoint point1)
{
    OKPoint p; p.x = point1.x; p.y = point1.y; p.z = point1.z; return p;
}

/* Calculate the magnitude */

CG_INLINE float
__OKPointMag(OKPoint point1)
{
    return sqrt((point1.x * point1.x) + (point1.y * point1.y) + (point1.z * point1.z));
}
#define OKPointMag __OKPointMag

/* Add vector to vector */

CG_INLINE OKPoint
OKPointAdd(OKPoint point1, OKPoint point2)
{
    OKPoint p; p.x = (point1.x + point2.x); p.y = (point1.y + point2.y); p.z = (point1.z + point2.z); return p;
}

/* Add float to vector */

CG_INLINE OKPoint
OKPointAddf(OKPoint point1, float n)
{
    OKPoint p; p.x = (point1.x + n); p.y = (point1.y + n); p.z = (point1.z + n); return p;
}
/* Remove vector from vector */

CG_INLINE OKPoint
OKPointSub(OKPoint point1, OKPoint point2)
{
    OKPoint p; p.x = (point1.x - point2.x); p.y = (point1.y - point2.y); p.z = (point1.z - point2.z); return p;
}

/* Multiply vector by vector */

CG_INLINE OKPoint
OKPointMult(OKPoint point1, OKPoint point2)
{
    OKPoint p; p.x = (point1.x * point2.x); p.y = (point1.y * point2.y); p.z = (point1.z * point2.z); return p;
}

/* Divide vector by vector */

CG_INLINE OKPoint
OKPointDiv(OKPoint point1, OKPoint point2)
{
    OKPoint p; p.x = (point1.x / point2.x); p.y = (point1.y / point2.y); p.z = (point1.z / point2.z); return p;
}

/* Multiply vector by float */

CG_INLINE OKPoint
OKPointMultf(OKPoint point1, float n)
{
    OKPoint p; p.x = (point1.x * n); p.y = (point1.y * n); p.z = (point1.z * n); return p;
}

/* Divide vector by float */

CG_INLINE OKPoint
OKPointDivf(OKPoint point1, float n)
{
    OKPoint p; p.x = (point1.x / n); p.y = (point1.y / n); p.z = (point1.z / n); return p;
}

/* Distance float to vector */

CG_INLINE float
OKPointDist(OKPoint point1, OKPoint point2)
{
    float dx = point1.x - point2.x;
    float dy = point1.y - point2.y;
    float dz = point1.z - point2.z;
    return sqrtf(dx*dx + dy*dy + dz*dz);
}

CG_INLINE CGPoint
CGPointFromOKPoint(OKPoint point1)
{
    return CGPointMake(point1.x, point1.y);
}

CG_INLINE OKPoint
OKPointFromCGPoint(CGPoint point1)
{
    return OKPointMake(point1.x, point1.y, 0.0);
}

////////////////END////////////////

#endif /* OKGEOMETRY_H_ */
