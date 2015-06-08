//
//  OKPoEMMProperties.m
//  OKPoEMM
//
//  Created by Christian Gratton on 2013-02-18.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "OKPoEMMProperties.h"

// Properties name constants of static parameters (plist)
// These values can be used throughout different poemm apps, they should not change
NSString* const Text = @"Text"; // current package
NSString* const Title = @"Title";
NSString* const Default = @"DefaultPoem";
NSString* const TextFile = @"TextFile";
NSString* const TextVersion = @"TextVersion";
NSString* const AuthorImage = @"AuthorImage";
NSString* const FontFile = @"FontFile";
NSString* const FontOutlineFile = @"FontOutlineFile";
NSString* const FontTessellationFile = @"FontTessellationFile";

// This will be unique to each poemm app, you will need to create a unique property for each different value that appears in the plist

//Rattlenakes
NSString* const BackgroundColor = @"BackgroundColor";
NSString* const SnakeFont = @"SnakeFont";
NSString* const SnakeFontSize = @"SnakeFontSize";
NSString* const SnakeFontScaling = @"SnakeFontScaling";
NSString* const SnakeFile = @"SnakeFile";
NSString* const SnakeColor = @"SnakeColor";
NSString* const TextFont = @"TextFont";
NSString* const TextVerticalMargin = @"TextVerticalMargin";
NSString* const TextHorizontalMargin = @"TextHorizontalMargin";
NSString* const TextColor = @"TextColor";
NSString* const TextFadeInSpeed = @"TextFadeInSpeed";
NSString* const TextFadeOutSpeed = @"TextFadeOutSpeed";
NSString* const UnbitableMargin = @"UnbitableMargin";
NSString* const SnakeBiteMass = @"SnakeBiteMass";
NSString* const SnakeBiteStrenghtMult = @"SnakeBiteStrenghtMult";
NSString* const SnakeBiteMinDistance = @"SnakeBiteMinDistance";
NSString* const SnakeBiteOpacityTrigger = @"SnakeBiteOpacityTrigger";
NSString* const SnakeScalingFactors = @"SnakeScalingFactors";
NSString* const SnakeScalingPositions= @ "SnakeScalingPositions";
NSString* const TextChangeInterval = @"TextChangeInterval";
NSString* const TextChangeSpeed = @"TextChangeSpeed";
NSString* const IdleInterval = @"IdleInterval";
NSString* const BgSnakeInterval = @"BgSnakeInterval";
NSString* const BgSnakeOpacity = @"BgSnakeOpacity";
NSString* const FirstBiteDelay = @"FirstBiteDelay";
NSString* const NextBiteMinimumDelay = @"NextBiteMinimumDelay";
NSString* const NextBiteMaximumDelay = @"NextBiteMaximumDelay";
//.....
NSString* const PhysicsGravity = @"PhysicsGravity";
NSString* const PhysicsDrag = @"PhysicsDrag";
NSString* const SmoothLevel = @"SmoothLevel";

NSString* const ShiftSoundsTime = @"ShiftSoundsTime";
NSString* const AmbientVolumeStart = @"AmbientVolumeStart";
NSString* const AmbientVolumeEnd = @"AmbientVolumeEnd";
NSString* const ThreatVolume = @"ThreatVolume";
NSString* const RattleVolume = @"RattleVolume";
NSString* const StrikeVolume = @"StrikeVolume";
NSString* const FirstStrikeSndFile = @"FirstStrikeSndFile";


// White.mm
//NSString* const BackgroundColor = @"BackgroundColor";
NSString* const BackgroundTextSpeed = @"BackgroundTextSpeed";
NSString* const BackgroundTextHorizontalMargin = @"BackgroundTextHorizontalMargin";
NSString* const BackgroundTextVerticalMargin = @"BackgroundTextVerticalMargin";
NSString* const BackgroundTextScale = @"BackgroundTextScale";
NSString* const BackgroundTextLeadingScalar = @"BackgroundTextLeadingScalar";
NSString* const MaximumSentences = @"MaximumSentences";
NSString* const BackgroundFlickerSpeed = @"BackgroundFlickerSpeed";
NSString* const BackgroundFlickerPropability = @"BackgroundFlickerPropability";
NSString* const BackgroundFlickerScalar = @"BackgroundFlickerScalar";
NSString* const MaximumFadingLines = @"MaximumFadingLines";

// Line.m
NSString* const MaximumSideWords = @"MaximumSideWords";
NSString* const FadeInOpacity = @"FadeInOpacity";
NSString* const FadeOutOpacity = @"FadeOutOpacity";
NSString* const FadeOutSpeed = @"FadeOutSpeed";
NSString* const FadeInSpeedHighlight = @"FadeInSpeedHighlight";
NSString* const FadeOutSpeedHighlight = @"FadeOutSpeedHighlight";
NSString* const FadeSpeedScroll = @"FadeSpeedScroll";
NSString* const ScrollDrag = @"ScrollDrag";
NSString* const ScrollSpeed = @"ScrollSpeed";
NSString* const MaximumDistanceMultiplier = @"MaximumDistanceMultiplier";
NSString* const MaximumDistancePadding = @"MaximumDistancePadding";
NSString* const MaximumSidePreloadWords = @"MaximumSidePreloadWords";
NSString* const MaximumFadeOutSpeedHighlight = @"MaximumFadeOutSpeedHighlight";
NSString* const TouchOffset = @"TouchOffset";
NSString* const OffsetSpeedScalar = @"OffsetSpeedScalar";

// Word.m
NSString* const WordFillColor = @"WordFillColor";
NSString* const WordTessellationAccurracy = @"WordTessellationAccurracy";

// OutlinedWord.m
NSString* const OutlinedWordFillColor = @"OutlinedWordFillColor";
NSString* const OutlinedWordOutlineColor = @"OutlinedWordOutlineColor";
NSString* const OutlinedWordTessellationAccurracy = @"OutlinedWordTessellationAccurracy";

// TessGlyph.mm
NSString* const OutlineWidth = @"OutlineWidth";
NSString* const RenderPadding = @"RenderPadding";

// Property name constant of dynamic paramaters
NSString* const Orientation = @"Orientation";
NSString* const UprightAngle = @"UprightAngle";

@implementation OKPoEMMProperties

+ (UIDeviceOrientation) orientation { return [(NSNumber*)[super objectForKey:Orientation] intValue]; };

+ (void) setOrientation:(UIDeviceOrientation)aOrientation
{
    // If orientation is the same as current, then do nothing
    if([self orientation] == aOrientation) return;
    
    // Only accept certain orientations
    if ((aOrientation != UIDeviceOrientationLandscapeLeft) && (aOrientation != UIDeviceOrientationLandscapeRight) && (aOrientation != UIDeviceOrientationPortrait) && (aOrientation != UIDeviceOrientationPortraitUpsideDown)) return;
    
    // Set the orientation
    [[super sharedInstance].properties setValue:[NSNumber numberWithInt:aOrientation] forKey:Orientation];
    
    // Adjust the UprightAngle to match
    if (aOrientation == UIDeviceOrientationLandscapeLeft)
		[[super sharedInstance].properties setValue:[NSNumber numberWithInt:90] forKey:UprightAngle];
	else if (aOrientation == UIDeviceOrientationLandscapeRight)
		[[super sharedInstance].properties setValue:[NSNumber numberWithInt:-90] forKey:UprightAngle];
	else if (aOrientation == UIDeviceOrientationPortrait)
		[[super sharedInstance].properties setValue:[NSNumber numberWithInt:0] forKey:UprightAngle];
	else if (aOrientation == UIDeviceOrientationPortraitUpsideDown)
		[[super sharedInstance].properties setValue:[NSNumber numberWithInt:180] forKey:UprightAngle];
}

+ (int) uprightAngle { return [(NSNumber*)[super objectForKey:UprightAngle] intValue]; }

+ (void) initWithContentsOfFile:(NSString *)aPath
{        
    // Insert an empty dictionary as an object     
    [OKAppProperties setObject:[[NSMutableDictionary alloc] init] forKey:@"OKPoEMMProperties"];
    
    // Set default orientation to unknown
    [OKPoEMMProperties setOrientation:UIDeviceOrientationUnknown];
}

+ (id) objectForKey:(id)aKey { return [[OKAppProperties objectForKey:@"OKPoEMMProperties"] objectForKey:aKey]; }

+ (void) setObject:(id)aObject forKey:(id)aKey
{
    [[OKAppProperties objectForKey:@"OKPoEMMProperties"] setObject:aObject forKey:aKey];
}

// Fills the properties with a loaded package dictionary (Properties-iPhone, Properties-iPhone-Retina, Properties-iPhone-568h, Properties-iPad, Properties-iPad-Retina)
+ (void) fillWith:(NSDictionary *)aTextDict
{    
    for(NSString *key in [aTextDict allKeys])
    {
        if([key rangeOfString:@"Properties-"].location != NSNotFound)
        {
            // Check if properties of device
            if([key isEqualToString:[NSString stringWithFormat:@"Properties-%@", [OKAppProperties deviceType]]])
            {
                NSDictionary *properties = [aTextDict objectForKey:[NSString stringWithFormat:@"Properties-%@", [OKAppProperties deviceType]]];
                
                for(NSString *propertyKey in [properties allKeys])
                {
                    [OKPoEMMProperties setObject:[properties objectForKey:propertyKey] forKey:propertyKey];
                }
            }
        }
        else
        {
            [OKPoEMMProperties setObject:[aTextDict objectForKey:key] forKey:key];
        }
    }
}

+ (void) listProperties { NSLog(@"listProperties %@", [OKAppProperties objectForKey:@"OKPoEMMProperties"]); }

@end
