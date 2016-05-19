//The MIT License (MIT)
//
//Copyright (c) 2014 Bryan Antigua <antigua.b@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

#import "Constants.h"
#import <UIKit/UIKit.h>

@interface BAFluidView : UIView


/**
Changes the fill color of the wave animation
 */
@property(strong,nonatomic) UIColor *fillColor;

/**
 Changes the stroke color of the wave animation
 */
@property(strong,nonatomic) UIColor *strokeColor;

/**
 Changes how frequently the vertical fill animation will happen
 */
@property(assign,nonatomic) CGFloat fillRepeatCount;

/**
 Provides a way to increase or decrese the side of the stroke around the wave animation
 */
@property(assign,nonatomic) CGFloat lineWidth;

/**
 Boolean to determine whether you want the fill animation to return to it's initial state
 */
@property(assign,nonatomic) BOOL fillAutoReverse;

/**
 CFTimeInterval to determine the total duration of a complete fill (0% - 100%)
 */
@property(assign,nonatomic) CFTimeInterval fillDuration;

/**
 Changes the interval between Max and Min the random function will use
 */
@property (assign,nonatomic) int amplitudeIncrement;

/**
 Changes the maximum wave crest
 */
@property (assign,nonatomic) int maxAmplitude;

/**
 Changes the minimum wave crest
 */
@property (assign,nonatomic) int minAmplitude;

/**
 Notification message string for tilt animations
 */
extern NSString * const kBAFluidViewCMMotionUpdate;

/**
 Returns an object that can create the fluid animation with the given wave properties. This init function lets you adjust the wave crest properties.
 
 @param aRect
 Frame for the fluid object to fill
 @param maxAmplitude
 Max wave crest
 @param minAmplitude
 Min wave crest
 @param amplitudeIncrement
 Lets you chose the interval between Max and Min the random function will use
 @return a fluid view object with the properties defined
 */
- (id)initWithFrame:(CGRect)aRect maxAmplitude:(int)maxAmplitude minAmplitude:(int)minAmplitude amplitudeIncrement:(int)amplitudeIncrement;

/**
 Returns an object that can create the fluid animation with the given wave properties. This init function lets you adjust starting elevation. The other parameters have default values.
 
 @param aRect
 Frame for the fluid object to fill
 @param startElevation
 The starting point of the fluid animation
 @return a fluid view object with the properties defined
 */
- (id)initWithFrame:(CGRect)aRect startElevation:(NSNumber*)aStartElevation;

/**
 Returns an object that can create the fluid animation with the given wave properties. This init function lets you adjust all the wave crest and fluid properties.
 
 @param aRect
 Frame for the fluid object to fill
 @param maxAmplitude
 Max wave crest
 @param minAmplitude
 Min wave crest
 @param amplitudeIncrement
 Lets you chose the interval between Max and Min the random function will use
 @param startElevation
 The starting point of the fluid animation
 @return a fluid view object with the properties defined
 */
- (id)initWithFrame:(CGRect)aRect maxAmplitude:(int)aMaxAmplitude minAmplitude:(int)aMinAmplitude amplitudeIncrement:(int)aAmplitudeIncrement startElevation:(NSNumber*)aStartElevation;

/**
This method lets you choose to what level you want the fluidVIew to increase or decrease to (based on starting elevation)
 @param fillPercentage
 Determines the percentage to fill to (decimal number)
 */
- (void)fillTo:(NSNumber*)fillPercentage;

/**
 This method lets you keep the fluid view at it's starting elevation, but creates the wave crest animation
 */
- (void)keepStationary;

/**
 This methods starts all the desired animations
 */
- (void)startAnimation;

/**
 This methods starts tils animations using accelerometer data
 */
- (void)startTiltAnimation;

/**
 This methods stops all the desired animations
 */
- (void)stopAnimation;

/**
This method can set all the default values prior to start of animation
 */
- (void)initialize;

@end
