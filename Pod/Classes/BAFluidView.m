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
#import "UIColor+ColorWithHex.h"

@interface BAFluidView()

@property (strong,nonatomic) UIView *rootView;

@property (strong,nonatomic) CAShapeLayer *lineLayer;

@property (strong,nonatomic) NSArray *amplitudeArray;
@property (assign,nonatomic) int startingAmplitude;

@property (strong,nonatomic) NSNumber* startElevation;
@property (assign,nonatomic) double primativeStartElevation;

@property (strong,nonatomic) NSNumber* fillLevel;
@property (assign,nonatomic) BOOL initialFill;

@property (assign,nonatomic) BOOL animating;

@property (assign,nonatomic) int waveLength;//** 2 UIBezierPaths = 1 wavelength
@property (assign,nonatomic) int finalX;

@property (strong,nonatomic) CAKeyframeAnimation *waveCrestAnimation;

@property (assign,nonatomic) UIDeviceOrientation orientation;

@property (assign,nonatomic) NSTimer *waveCrestTimer;

@end

@implementation BAFluidView


#pragma mark - Lifecycle

-  (id)initWithFrame:(CGRect)aRect maxAmplitude:(int)aMaxAmplitude minAmplitude:(int)aMinAmplitude amplitudeIncrement:(int)aAmplitudeIncrement
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        [self initialize];
        
        //setting custom wave properties
        self.maxAmplitude = aMaxAmplitude;
        self.minAmplitude = aMinAmplitude;
        self.amplitudeIncrement = aAmplitudeIncrement;
        self.amplitudeArray = [self createAmplitudeOptions];
    }
    return self;
}

-  (id)initWithFrame:(CGRect)aRect maxAmplitude:(int)aMaxAmplitude minAmplitude:(int)aMinAmplitude amplitudeIncrement:(int)aAmplitudeIncrement startElevation:(NSNumber*)aStartElevation
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        [self initialize];
        
        //setting custom wave properties
        self.maxAmplitude = aMaxAmplitude;
        self.minAmplitude = aMinAmplitude;
        self.amplitudeIncrement = aAmplitudeIncrement;
        self.amplitudeArray = [self createAmplitudeOptions];
        [self setStartElavation:aStartElevation];;
    }
    return self;
}


-  (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        [self initialize];
        
    }
    return self;
}

-  (id)initWithFrame:(CGRect)aRect startElevation:(NSNumber*)aStartElevation
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        [self initialize];
        [self setStartElavation:aStartElevation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if(newWindow == nil){
        //the view is being removed
        [self stopAnimation];
        return;
    }
    
    //the view is being added
    [self startAnimation];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //layout only if device has change orientation
    if(self.orientation != [[UIDevice currentDevice] orientation]){
        
        self.orientation = [[UIDevice currentDevice] orientation];
        
        //I can either remove the animation and have a slight lag or the user can see one animation where the wave
        //still has the frame of the old orientation.
        [self.lineLayer removeAllAnimations];
        [self stopAnimation];
        [self reInitializeLayer];
        [self startAnimation];
    }
}

#pragma mark - Custom Accessors

- (void)setFillColor:(UIColor *)fillColor{
    _fillColor = fillColor;
    self.lineLayer.fillColor = [fillColor CGColor];
}

- (void)setStrokeColor:(UIColor *)strokeColor{
    _strokeColor = strokeColor;
    self.lineLayer.strokeColor = [strokeColor CGColor];
}

- (void)setLineWidth:(CGFloat)lineWidth{
    _lineWidth = lineWidth;
    self.lineLayer.lineWidth = lineWidth;
}

- (void)setFillAutoReverse:(BOOL)fillAutoReverse {
    _fillAutoReverse = fillAutoReverse;
}

- (void)setFillRepeatCount:(CGFloat)fillRepeatCount {
    _fillRepeatCount= fillRepeatCount;
}

- (void)setStartElavation:(NSNumber *)startElavation {
    _startElavation = startElavation;
    CGRect frame = self.lineLayer.frame;
    frame.origin.y = CGRectGetHeight(self.rootView.frame)*((1-[_startElavation floatValue]));
    self.lineLayer.frame = frame;
    self.primativeStartElevation = [startElavation doubleValue];
    
}

- (void)setMaxAmplitude:(int)maxAmplitude {
    _maxAmplitude = maxAmplitude;
    self.amplitudeArray = [self createAmplitudeOptions];
}

- (void)setMinAmplitude:(int)minAmplitude {
    _minAmplitude = minAmplitude;
    self.amplitudeArray = [self createAmplitudeOptions];
}

- (void)setAmplitudeIncrement:(int)amplitudeIncrement {
    _amplitudeIncrement = amplitudeIncrement;
    self.amplitudeArray = [self createAmplitudeOptions];
}

- (void)setFillDuration:(CFTimeInterval)fillDuration {
    _fillDuration = fillDuration;
}



#pragma mark - Public

- (void)initialize {
    //find root view - the waves look weird if you go only by the size of the container
    //Also depending on how the view is initialized. You can find the root view intwo ways.
    self.rootView = [self.window.subviews objectAtIndex:0];
    if (!self.rootView) {
        self.rootView = self;
        while (self.rootView.superview != nil) {
            self.rootView = self.rootView.superview;
        }
    }
    
    self.orientation = [[UIDevice currentDevice] orientation];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // create the wave layer and make it blue
    self.clipsToBounds = YES;
    self.lineLayer = [CAShapeLayer layer];
    self.lineLayer.fillColor = [UIColor colorWithHex:0x6BB9F0].CGColor;
    self.lineLayer.strokeColor = [UIColor colorWithHex:0x6BB9F0].CGColor;
    
    //default wave properties
    self.fillAutoReverse = YES;
    self.fillRepeatCount = HUGE_VALF;
    self.amplitudeIncrement = 5;
    self.maxAmplitude = 40;
    self.minAmplitude = 5;
    self.startingAmplitude = self.maxAmplitude;
    self.waveLength = CGRectGetWidth(self.rootView.frame);
    self.startElevation = @0;
    self.fillDuration = 7.0;
    self.finalX = 2*self.waveLength;
    
    //available amplitudes
    self.amplitudeArray = [NSArray arrayWithArray:[self createAmplitudeOptions]];
    
    //creating a linelayer frame
    self.lineLayer.anchorPoint= CGPointMake(0, 0);
    CGRect frame = CGRectMake(0, CGRectGetHeight(self.frame), self.finalX, CGRectGetHeight(self.rootView.frame));
    self.lineLayer.frame = frame;
    
    //fill level
    self.initialFill = YES;
    self.fillLevel = @0.0;
    
    //adding notification for when the app enters the foreground/background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopAnimation)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startAnimation)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)startAnimation {
    if (!self.animating) {
        self.startingAmplitude = self.maxAmplitude;
        
        //Phase Shift Animation
        CAKeyframeAnimation *horizontalAnimation =
        [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
        horizontalAnimation.values = @[@(self.lineLayer.position.x),@(-self.finalX + self.waveLength)];
        horizontalAnimation.duration = 1.0;
        horizontalAnimation.repeatCount = HUGE;
        [self.lineLayer addAnimation:horizontalAnimation forKey:@"horizontalAnimation"];
        
        //Wave Crest Animations
        self.waveCrestAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        self.waveCrestAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        self.waveCrestAnimation.values = [self getBezierPathValues];
        self.waveCrestAnimation.duration = 0.5;
        self.waveCrestAnimation.removedOnCompletion = NO;
        self.waveCrestAnimation.fillMode = kCAFillModeForwards;
        self.waveCrestAnimation.delegate = self;
        self.waveCrestTimer = [NSTimer scheduledTimerWithTimeInterval:self.waveCrestAnimation.duration
                                                               target:self
                                                             selector:@selector(updateWaveCrestAnimation)
                                                             userInfo:nil
                                                              repeats:YES];
        
        //add sublayer to view
        [self.layer addSublayer:self.lineLayer];
        
        self.animating = YES;
    }
}

- (void)stopAnimation {
    if (self.waveCrestTimer) {
        [self.waveCrestTimer invalidate];
        self.waveCrestTimer = nil;
    }
    [self.lineLayer removeAnimationForKey:@"horizontalAnimation"];
    [self.lineLayer removeAnimationForKey:@"waveCestAnimation"];
    self.waveCrestAnimation =  nil;
    self.animating = NO;
}

- (void)keepStationary {
    [self.lineLayer removeAnimationForKey:@"verticalAnimation"];
}

- (void)fillTo:(NSNumber*)fillPercentage {
    self.fillLevel = fillPercentage;
    
    CAKeyframeAnimation *verticalAnimation =
    [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    float finalPosition;
    finalPosition = (1.0 - [fillPercentage doubleValue])*CGRectGetHeight(self.frame);
    
    //bit hard to define a hard endpoint with the dynamic waves
    if ([self.fillLevel  isEqual: @1.0]){
        finalPosition = finalPosition - 2*self.maxAmplitude;
    }
    else if ([self.fillLevel doubleValue] > 0.98) {
        finalPosition = finalPosition - self.maxAmplitude;
    }
    
    
    //fill animation
    //the animation glitches because the horizontal x of the layer is never in the same spot at the end of the animation. We can use the presentation layer to get the current x. This isn't what the presentation layer is for, but can't find a way to make a smooth transition.
    CALayer *initialLayer = self.lineLayer;
    
    if (!self.initialFill) {
        initialLayer = self.lineLayer.presentationLayer;
    }
    verticalAnimation.values = @[@(initialLayer.position.y),@(finalPosition)];
    verticalAnimation.duration = self.fillDuration*[fillPercentage doubleValue];
    verticalAnimation.autoreverses = self.fillAutoReverse;
    verticalAnimation.repeatCount = self.fillRepeatCount;
    verticalAnimation.removedOnCompletion = NO;
    verticalAnimation.fillMode = kCAFillModeForwards;
    [self.lineLayer addAnimation:verticalAnimation forKey:@"verticalAnimation"];
    self.initialFill = NO;
    
}

#pragma mark - Private

- (void)reInitializeLayer {
    //This method occurs when the device is rotated
    
    self.rootView = [self.window.subviews objectAtIndex:0];
    if (!self.rootView) {
        self.rootView = self;
        while (self.rootView.superview != nil) {
            self.rootView = self.rootView.superview;
        }
    }
    
    //values that need to be adjusted due to change in width
    self.waveLength = CGRectGetWidth(self.rootView.frame);
    self.finalX = 2*self.waveLength;
    
    //creating the linelayer frame to fit new orientation
    self.lineLayer.anchorPoint= CGPointMake(0, 0);
    CGRect frame = CGRectMake(0, CGRectGetHeight(self.frame), self.finalX, CGRectGetHeight(self.rootView.frame));
    self.lineLayer.frame = frame;
    
    //need to grab the presentation again as a base
    self.initialFill = YES;
    
    //for some reason I can't access _startElevation, but a primitive can be accessed. Right now
    //all this does is redo the elevation adjustment due to change in height of device
    self.startElavation = @(self.primativeStartElevation);
    
    
    //the animation for fill will have to repeat as the height as changed
    if (![self.fillLevel isEqual:@0]) {
        [self fillTo:self.fillLevel];
    }
}

- (void)updateWaveCrestAnimation {
    
    //Wave Crest animation
    [self.lineLayer removeAnimationForKey:@"waveCrestAnimation"];
    self.waveCrestAnimation.values = [self getBezierPathValues];
    [self.lineLayer addAnimation:self.waveCrestAnimation forKey:@"waveCrestAnimation"];
    
}

- (NSArray*)getBezierPathValues {
    //creating wave starting point
    CGPoint startPoint;
    startPoint = CGPointMake(0,0);
    
    //grabbing random amplitude to shrink/grow to
    NSNumber *index = [NSNumber numberWithInt:arc4random_uniform(7)];
    
    int finalAmplitude = [[self.amplitudeArray objectAtIndex:[index intValue]] intValue];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    //shrinking
    if (self.startingAmplitude >= finalAmplitude) {
        for (int j = self.startingAmplitude; j >= finalAmplitude; j-=self.amplitudeIncrement) {
            //create a UIBezierPath along distance
            UIBezierPath* line = [UIBezierPath bezierPath];
            [line moveToPoint:startPoint];
            int tempAmplitude = j;
            for (int i = self.waveLength/2; i <= self.finalX; i+=self.waveLength/2) {
                [line addQuadCurveToPoint:CGPointMake(startPoint.x + i,startPoint.y) controlPoint:CGPointMake(startPoint.x + i -(self.waveLength/4),startPoint.y + tempAmplitude)];
                tempAmplitude = -tempAmplitude;
            }
            
            [line addLineToPoint:CGPointMake(self.finalX, 2*CGRectGetHeight(self.rootView.frame) - self.maxAmplitude)];
            [line addLineToPoint:CGPointMake(0, 2*CGRectGetHeight(self.rootView.frame) - self.maxAmplitude)];
            [line closePath];
            
            [values addObject:(id)line.CGPath];
        }
        
    }
    
    //growing
    else{
        for (int j = self.startingAmplitude; j <= finalAmplitude; j+=self.amplitudeIncrement) {
            //create a UIBezierPath along distance
            UIBezierPath* line = [UIBezierPath bezierPath];
            [line moveToPoint:startPoint];
            
            int tempAmplitude = j;
            for (int i = self.waveLength/2; i <= self.finalX; i+=self.waveLength/2) {
                [line addQuadCurveToPoint:CGPointMake(startPoint.x + i,startPoint.y) controlPoint:CGPointMake(startPoint.x + i -(self.waveLength/4),startPoint.y + tempAmplitude)];
                tempAmplitude = -tempAmplitude;
            }
            
            [line addLineToPoint:CGPointMake(self.finalX, 2*CGRectGetHeight(self.rootView.frame) - self.maxAmplitude)];
            [line addLineToPoint:CGPointMake(0, 2*CGRectGetHeight(self.rootView.frame) - self.maxAmplitude)];
            [line closePath];
            
            [values addObject:(id)line.CGPath];
        }
        
        
    }
    
    self.startingAmplitude = finalAmplitude;
    
    return [NSArray arrayWithArray:values];
    
}

- (NSArray*)createAmplitudeOptions {
    NSMutableArray *tempAmplitudeArray = [[NSMutableArray alloc] init];
    for (int i = self.minAmplitude; i <= self.maxAmplitude; i+= self.amplitudeIncrement) {
        [tempAmplitudeArray addObject:[NSNumber numberWithInt:i]];
    }
    return tempAmplitudeArray;
}

@end
