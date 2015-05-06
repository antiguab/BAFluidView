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

#import "BAViewController.h"
#import "BAFluidView.h"
#import "BAUtil.h"

@interface BAViewController ()

    @property (strong,nonatomic) UIDynamicAnimator *animator;
    @property (strong,nonatomic) UIAttachmentBehavior *attachmentBehavior;

    @property (strong,nonatomic) UIPanGestureRecognizer *gestureRecognizer;
    @property (strong,nonatomic) CABasicAnimation *fadeIn;
    @property (strong,nonatomic) CABasicAnimation *fadeOut;

    @property (strong,nonatomic) NSMutableArray *examplesArray;
    @property (strong,nonatomic) UIView *container;

    @property (assign,nonatomic) int currentExample;
    @property (assign,nonatomic) BOOL activity;
    @property (assign,nonatomic) NSTimer *timer;

@end

@implementation BAViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.activity = NO;

    [self setUpBackground];

    self.container = [self nextBAFluidViewExample];

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [self.container addGestureRecognizer:self.gestureRecognizer];

    self.currentExample = 0;
    
    [self.view insertSubview:self.container belowSubview:self.swipeForNextExampleLabel];
    
    self.fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    self.fadeIn.duration = 2.0;
    self.fadeIn.fromValue = @0.0f;
    self.fadeIn.toValue = @1.0f;
    self.fadeIn.removedOnCompletion = NO;
    self.fadeIn.fillMode = kCAFillModeForwards;
    self.fadeIn.additive = NO;
    
    self.fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    self.fadeOut.duration = 0.5f;
    self.fadeOut.fromValue = @1.0f;
    self.fadeOut.toValue = @0.0f;
    self.fadeOut.removedOnCompletion = NO;
    self.fadeOut.fillMode = kCAFillModeForwards;
    self.fadeOut.additive = NO;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(showSwipeForNextExampleLabel)
                                   userInfo:nil
                                    repeats:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Timer

- (void)startTimer {
    if(self.timer != nil){
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(showSwipeForNextExampleLabel)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Gestures

-(void)panDetected:(UIPanGestureRecognizer*) gesture {
    
    CGPoint locationInContainer = [gesture locationInView:gesture.view];
    CGPoint locationinSuperView = [gesture locationInView:self.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        //assign the attachment behavior as the view is starting to move
        [self.animator removeAllBehaviors];
        UIOffset offset = UIOffsetMake(locationInContainer.x - CGRectGetMidX(self.container.bounds), locationInContainer.y - CGRectGetMidY(self.container.bounds));
        self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.container offsetFromCenter:offset attachedToAnchor:locationinSuperView];
        [self.animator addBehavior:self.attachmentBehavior];
        
    }
    
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        //update based on where finger is
        self.attachmentBehavior.anchorPoint = locationinSuperView;
        self.activity = YES;
        
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        //transition to the next example if swiped down far enough
        [self.animator removeAllBehaviors];
        UISnapBehavior *snapBehavior =[[UISnapBehavior alloc] initWithItem:self.container snapToPoint:self.view.center];
        [self.animator addBehavior:snapBehavior];
        
        if([gesture translationInView:self.view].y > 150 ) {
            [self transitionToNextExample];
        }
    }
}

#pragma mark - Private

- (void)showSwipeForNextExampleLabel {
    //call to action in case user doesn't swipe
    if (!self.activity) {
        [self stopTimer];
        [self.swipeForNextExampleLabel.layer removeAllAnimations];
        self.swipeForNextExampleLabel.layer.opacity = 1;
        [self.swipeForNextExampleLabel.layer addAnimation:self.fadeIn forKey:@"fadeIn"];
    }

}

- (void)hideSwipeForNextExampleLabel {
    [self.swipeForNextExampleLabel.layer removeAllAnimations];
    self.swipeForNextExampleLabel.layer.opacity = 0;
    [self.swipeForNextExampleLabel.layer addAnimation:self.fadeOut forKey:@"fadeOut"];
}


- (void)setUpBackground {
    //sets up the green background [for fun - even though there an image :) ]
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[BAUtil UIColorFromHex:0x53cf84].CGColor,(id)[BAUtil UIColorFromHex:0x53cf84].CGColor, (id)[BAUtil UIColorFromHex:0x2aa581].CGColor, (id)[BAUtil UIColorFromHex:0x1b9680].CGColor];
    gradient.locations = @[[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:0.5f],[NSNumber numberWithFloat:0.8f], [NSNumber numberWithFloat:1.0f]];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:gradient atIndex:0];
    
}


- (void)changeTitleColor:(UIColor*)color {
    
    //better contrast
    for (UILabel* label in self.TitleLabels) {
        [label setTextColor:color];
    }
}

-(void)transitionToNextExample{
    
    //This adds the dragging and falling functionality
    if(self.swipeForNextExampleLabel.alpha > 0){
        [self hideSwipeForNextExampleLabel];
    }
    
    [self startTimer];
    self.activity = NO;
    [self.animator removeAllBehaviors];
    
    UIGravityBehavior* gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self.container]];
    gravityBehaviour.gravityDirection = CGVectorMake(0.0, 10.0);
    [self.animator addBehavior:gravityBehaviour];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.container]];
    [itemBehaviour addAngularVelocity:-M_PI_2 forItem: self.container];
    [self.animator addBehavior:itemBehaviour];
    
    self.currentExample++;
    
    UIView *nextFluidViewExample = [self nextBAFluidViewExample];
    [nextFluidViewExample addGestureRecognizer:self.gestureRecognizer];
    nextFluidViewExample.alpha = 0.0;
    [self.view insertSubview:nextFluidViewExample belowSubview:self.swipeForNextExampleLabel];
    
    [UIView animateWithDuration:0.5 animations:^{
        nextFluidViewExample.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.container = nextFluidViewExample;
    }];
    
}

-(UIView*) nextBAFluidViewExample {
    BAFluidView *fluidView;

    switch (self.currentExample) {
        case 0://Example with a mask
        {
            //TO DO add feature to pic a starting elevation
            CGRect frame = self.view.frame;
            frame.origin .y += 40;
            fluidView = [[BAFluidView alloc] initWithFrame:frame];
            fluidView.fillColor = [BAUtil UIColorFromHex:0x397ebe];
            UIImage *maskingImage = [UIImage imageNamed:@"icon"];
            CALayer *maskingLayer = [CALayer layer];
         
            maskingLayer.frame = CGRectMake(CGRectGetMidX(fluidView.frame) - maskingImage.size.width/2, 70, maskingImage.size.width, maskingImage.size.height);
            [maskingLayer setContents:(id)[maskingImage CGImage]];
            [fluidView.layer setMask:maskingLayer];
            [self changeTitleColor:[BAUtil UIColorFromHex:0x2e353d]];
            return fluidView;
        }
            
        case 1://example with a fill of the screen
            fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame startElevation:@0.0];
            fluidView.fillColor = [BAUtil UIColorFromHex:0x397ebe];
            [self changeTitleColor:[UIColor whiteColor]];
            return fluidView;
            
        case 2://Example with a different color and stationary
            fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
            fluidView.fillColor = [BAUtil UIColorFromHex:0x2e353d];
            [fluidView keepStationary];
            [self changeTitleColor:[UIColor whiteColor]];
            return fluidView;
            
        case 3://Example with clear fill color
            fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
            fluidView.fillColor = [UIColor clearColor];
            fluidView.strokeColor = [UIColor whiteColor];
            [fluidView keepStationary];
            [self changeTitleColor:[BAUtil UIColorFromHex:0x2e353d]];
            return fluidView;
        default:
            self.currentExample = 0;
            return [self nextBAFluidViewExample];
    }
    
    return nil;
}

@end
