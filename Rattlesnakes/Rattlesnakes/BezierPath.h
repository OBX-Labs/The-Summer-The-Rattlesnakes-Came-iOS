//
//  BezierPath.h
//  
//
//  Created by Serge on 2013-05-16.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    FORWARD,
    BACKWARD
} PathDirection;

@interface BezierPath : NSObject
{

    //direction the point moves on the path
	/*static enum PathDirection {
		FORWARD, BACKWARD;
	}*/
    	
	//parent Processing applet
	//PApplet p;
	
	/*float s[];			//start point
	float [] c1;		//first control point
	float [] c2;		//second control point
	float [] e;			//end point
    */
    /*NSMutableArray *s;
    NSMutableArray *c1;
    NSMutableArray *c2;
    NSMutableArray *e;
    */
    
	NSArray *s;			//start point
    NSArray *c1;		//first control point
    NSArray *c2;		//second control point
    NSArray *e;
     
    
	float t;			//time or position on the path (0 to 1)
	PathDirection d;	//direction of the path
	float spd;			//speed at which the point moves on the path

}

-(id) initWithPositions:(float)sx sy:(float)sy c1x:(float)c1x c1y:(float)c1y c2x:(float)c2x c2y:(float)c2y ex:(float)ex ey:(float)ey;
-(void) reverse;
-(void) update;
-(BOOL) done;
-(void) end;



@end
