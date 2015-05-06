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

#import "BAFluidView.h"
#import "BAUtil.h"

@interface BAFluidView()
{
    CAShapeLayer *lineLayer;
    int finalX;
    
    NSArray *amplitudeArray;
    int amplitudeIncrement;
    int maxAmplitude;
    int minAmplitude;
    int startingAmplitude;
    NSNumber* startElevation;
    float fillLevel;
    int waveLength;//** 2 UIBezierPaths = 1 wavelength
    
    CAKeyframeAnimation *waveCrestAnimation;

    

}
@end

@implementation BAFluidView

-  (id)initWithFrame:(CGRect)aRect maxAmplitude:(int)aMaxAmplitude minAmplitude:(int)aMinAmplitude amplitudeIncrement:(int)aAmplitudeIncrement
{
    self = [super initWithFrame:aRect];
        
    if (self)
    {
        [self defaultInit];
        
        //setting custom wave properties
        maxAmplitude = aMaxAmplitude;
        minAmplitude = aMinAmplitude;
        amplitudeIncrement = aAmplitudeIncrement;
        amplitudeArray = [self createAmplitudeOptions];
        [self addAnimations];
    }
    return self;
}

-  (id)initWithFrame:(CGRect)aRect maxAmplitude:(int)aMaxAmplitude minAmplitude:(int)aMinAmplitude amplitudeIncrement:(int)aAmplitudeIncrement startElevation:(NSNumber*)aStartElevation
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        [self defaultInit];
        
        //setting custom wave properties
        maxAmplitude = aMaxAmplitude;
        minAmplitude = aMinAmplitude;
        amplitudeIncrement = aAmplitudeIncrement;
        amplitudeArray = [self createAmplitudeOptions];
        startElevation = aStartElevation;
        [self addAnimations];
    }
    return self;
}


-  (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        [self defaultInit];
        [self addAnimations];
        
    }
    return self;
}

-  (id)initWithFrame:(CGRect)aRect startElevation:(NSNumber*)aStartElevation
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        [self defaultInit];
        startElevation = aStartElevation;
        [self addAnimations];
        
    }
    return self;
}

-( void) defaultInit {
    // create the wave layer and make it blue
    self.clipsToBounds = YES;
    lineLayer = [CAShapeLayer layer];
    lineLayer.fillColor = [[BAUtil UIColorFromHex:0x6BB9F0] CGColor];
    lineLayer.strokeColor = [[BAUtil UIColorFromHex:0x6BB9F0] CGColor];
    //default wave properties
    self.fillAutoReverse = YES;
    self.fillRepeatCount = HUGE_VALF;
    amplitudeIncrement = 5;
    maxAmplitude = 40;
    minAmplitude = 5;
    startingAmplitude = maxAmplitude;
    waveLength = 320;
    startElevation = @50;
    finalX = self.frame.origin.x + 2*waveLength;
 
    //if wavelength is shorter than the view, keep extending the wave
    // we want enough waves to simulate one phase shift
    while(finalX < self.frame.size.width + waveLength*4) {
        finalX += 2*waveLength;
    }
    
    //available amplitudes
    amplitudeArray = [NSArray arrayWithArray:[self createAmplitudeOptions]];
    
}

- (void) setFillColor:(UIColor *)fillColor{
    _fillColor = fillColor;
    lineLayer.fillColor = [fillColor CGColor];
}

- (void) setStrokeColor:(UIColor *)strokeColor{
    _strokeColor = strokeColor;
    lineLayer.strokeColor = [strokeColor CGColor];
}

- (void) setLineWidth:(float)lineWidth{
    _lineWidth = lineWidth;
    lineLayer.lineWidth = lineWidth;
}

- (void) setFillAutoReverse:(BOOL)fillAutoReverse {
    _fillAutoReverse = fillAutoReverse;
    [self fillTo:fillLevel];
}

- (void) setFillRepeatCount:(float)fillRepeatCount {
    _fillRepeatCount= fillRepeatCount;
    [self fillTo:fillLevel];
}

-(void)addAnimations {
    startingAmplitude = maxAmplitude;
    
    //Wave Crest animation
    [self updateWaveSegmentAnimation];
    
    
    //Phase Shift Animation
    CAKeyframeAnimation *horizontalAnimation =
    [CAKeyframeAnimation animationWithKeyPath:@"position"];
    horizontalAnimation.values =  @[(id)[NSValue valueWithCGPoint:CGPointMake(lineLayer.position.x, lineLayer.position.y)],(id)[NSValue valueWithCGPoint:CGPointMake(lineLayer.position.x - waveLength, lineLayer.position.y)]];
    horizontalAnimation.additive = true;
    horizontalAnimation.duration = 1.0;
    horizontalAnimation.repeatCount = HUGE;
    horizontalAnimation.calculationMode = @"paced";
    [lineLayer addAnimation:horizontalAnimation forKey:@"horizontalAnimation"];
    
    //Wave Motion Animations
    fillLevel = 1.0;
    [self fillTo:fillLevel];
    waveCrestAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    waveCrestAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    waveCrestAnimation.values = [self getBezierPathValues];
    waveCrestAnimation.duration = 1.0;
    waveCrestAnimation.removedOnCompletion = NO;
    waveCrestAnimation.fillMode = kCAFillModeForwards;
    waveCrestAnimation.delegate = self;
    [self updateWaveSegmentAnimation];
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateWaveSegmentAnimation)
                                   userInfo:nil
                                    repeats:YES];
    
    //add sublayer to view
    [self.layer addSublayer:lineLayer];
}

-(void)keepStationary{
        [lineLayer removeAnimationForKey:@"verticalAnimation"];
}

-(void)fillTo:(float)percentage{
    fillLevel = percentage;
    CAKeyframeAnimation *verticalAnimation =
    [CAKeyframeAnimation animationWithKeyPath:@"position"];
    float finalPosition;
    finalPosition = (1.0 - percentage)*self.frame.size.height - (1 - [startElevation floatValue]/100)*self.frame.size.height;

    verticalAnimation.values =  @[(id)[NSValue valueWithCGPoint:lineLayer.position],(id)[NSValue valueWithCGPoint:CGPointMake(lineLayer.position.x, finalPosition - maxAmplitude)]];
    verticalAnimation.additive = true;
    verticalAnimation.duration = 7*percentage;
    verticalAnimation.autoreverses = self.fillAutoReverse;
    verticalAnimation.repeatCount = self.fillRepeatCount;
    verticalAnimation.removedOnCompletion = NO;
    verticalAnimation.fillMode = kCAFillModeForwards;
    verticalAnimation.calculationMode = @"paced";
    [lineLayer addAnimation:verticalAnimation forKey:@"verticalAnimation"];
}

-(void) updateWaveSegmentAnimation{
    //Wave Crest animation
    [lineLayer removeAnimationForKey:@"waveSegmentAnimation"];
    waveCrestAnimation.values = [self getBezierPathValues];
    [lineLayer addAnimation:waveCrestAnimation forKey:@"waveSegmentAnimation"];
}

- (NSArray*) getBezierPathValues{
    //creating wave starting point
    CGPoint startPoint;
    if (startElevation) {
        startPoint = CGPointMake(self.frame.origin.x, ((1 - [startElevation floatValue]/100))*self.frame.size.height);
    }
    else{
        startPoint = CGPointMake(self.frame.origin.x, self.frame.size.height/2);
    }
    //grabbing random amplitude to shrink/grow to
    NSNumber *index = [NSNumber numberWithInt:arc4random_uniform(7)];
    
    int finalAmplitude = [[amplitudeArray objectAtIndex:[index intValue]] intValue];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    //shrinking
    if (startingAmplitude >= finalAmplitude) {
        for (int j = startingAmplitude; j >= finalAmplitude; j-=amplitudeIncrement) {
            //create a UIBezierPath along distance
            UIBezierPath* line = [UIBezierPath bezierPath];
            [line moveToPoint:startPoint];
            int tempAmplitude = j;
            for (int i = waveLength/2; i <= finalX; i+=waveLength/2) {
                [line addQuadCurveToPoint:CGPointMake(startPoint.x + i,startPoint.y) controlPoint:CGPointMake(startPoint.x + i -(waveLength/4),startPoint.y + tempAmplitude)];
                tempAmplitude = -tempAmplitude;
            }
            
            [line addLineToPoint:CGPointMake(finalX, self.frame.size.height*4 - maxAmplitude)];
            [line addLineToPoint:CGPointMake(self.frame.origin.x, self.frame.size.height*4 - maxAmplitude)];
            [line closePath];
            
            [values addObject:(id)line.CGPath];
        }
        
    }
    
    //growing
    else{
        for (int j = startingAmplitude; j <= finalAmplitude; j+=amplitudeIncrement) {
            //create a UIBezierPath along distance
            UIBezierPath* line = [UIBezierPath bezierPath];
            [line moveToPoint:startPoint];
            
            int tempAmplitude = j;
            for (int i = waveLength/2; i <= finalX; i+=waveLength/2) {
                [line addQuadCurveToPoint:CGPointMake(startPoint.x + i,startPoint.y) controlPoint:CGPointMake(startPoint.x + i -(waveLength/4),startPoint.y + tempAmplitude)];
                tempAmplitude = -tempAmplitude;
            }
            
            [line addLineToPoint:CGPointMake(finalX, self.frame.size.height*4 - maxAmplitude)];
            [line addLineToPoint:CGPointMake(self.frame.origin.x, self.frame.size.height*4 - maxAmplitude)];
            [line closePath];
            
            [values addObject:(id)line.CGPath];
        }
        
        
    }
    
    startingAmplitude = finalAmplitude;
    
    return [NSArray arrayWithArray:values];
    
}

- (NSArray*)createAmplitudeOptions{
    NSMutableArray *tempAmplitudeArray = [[NSMutableArray alloc] init];
    for (int i = minAmplitude; i <= maxAmplitude; i+= amplitudeIncrement) {
        [tempAmplitudeArray addObject:[NSNumber numberWithInt:i]];
    }
    return tempAmplitudeArray;
}


@end
