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
#import "UIColor+ColorWithHex.h"
#import <CoreMotion/CoreMotion.h>

@interface BAViewController ()

@property (strong,nonatomic) UIDynamicAnimator *animator;

@property (strong,nonatomic) UIAttachmentBehavior *attachmentBehavior;

@property (strong,nonatomic) UIPanGestureRecognizer *gestureRecognizer;

@property (strong,nonatomic) CABasicAnimation *fadeIn;

@property (strong,nonatomic) CABasicAnimation *fadeOut;

@property (strong,nonatomic) NSMutableArray *examplesArray;

@property (assign,nonatomic) int currentExample;

@property (assign,nonatomic) BOOL activity;

@property (assign,nonatomic) NSTimer *timer;

@property (assign,nonatomic) BOOL firstTimeLoading;

@property(assign,nonatomic) CAGradientLayer *gradient;

@property(strong,nonatomic) CMMotionManager *motionManager;

@end

@implementation BAViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.activity = NO;
    self.firstTimeLoading = YES;
    
    [self setUpBackground];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    
    self.currentExample = 0;
    
    //For fading in swipe labels and timing it's appearance
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

- (void)viewDidLayoutSubviews {
    
    if (self.firstTimeLoading) {
        self.firstTimeLoading = NO;
        self.exampleContainerView = [self nextBAFluidViewExample];
        [self.view insertSubview:self.exampleContainerView belowSubview:self.swipeForNextExampleLabel];
        [self.exampleContainerView addGestureRecognizer:self.gestureRecognizer];
    }
    
    [self setUpBackground];

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //only need to snap back afterwards
         
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self.animator removeAllBehaviors];
         UISnapBehavior *snapBehavior =[[UISnapBehavior alloc] initWithItem:self.exampleContainerView snapToPoint:self.view.center];
         [self.animator addBehavior:snapBehavior];
         
     }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
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
        UIOffset offset = UIOffsetMake(locationInContainer.x - CGRectGetMidX(self.exampleContainerView.bounds), locationInContainer.y - CGRectGetMidY(self.exampleContainerView.bounds));
        self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.exampleContainerView offsetFromCenter:offset attachedToAnchor:locationinSuperView];
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
        UISnapBehavior *snapBehavior =[[UISnapBehavior alloc] initWithItem:self.exampleContainerView snapToPoint:self.view.center];
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
    if (self.gradient) {
        [self.gradient removeFromSuperlayer];
        self.gradient = nil;
    }
    
    //resetting a gradient layer causes the iphone6 simulator to fail (weird bug)
    CAGradientLayer *tempLayer = [CAGradientLayer layer];
    tempLayer.frame = self.view.bounds;
    tempLayer.colors = @[(id)[UIColor colorWithHex:0x53cf84].CGColor,(id)[UIColor colorWithHex:0x53cf84].CGColor, (id)[UIColor colorWithHex:0x2aa581].CGColor, (id)[UIColor colorWithHex:0x1b9680].CGColor];
    tempLayer.locations = @[[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:0.5f],[NSNumber numberWithFloat:0.8f], [NSNumber numberWithFloat:1.0f]];
    tempLayer.startPoint = CGPointMake(0, 0);
    tempLayer.endPoint = CGPointMake(1, 1);
    
    self.gradient = tempLayer;
    [self.backgroundView.layer insertSublayer:self.gradient atIndex:0];
    
}


- (void)changeTitleColor:(UIColor*)color {
    
    //better contrast
    for (UILabel* label in self.titleLabels) {
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
    
    //drop current example
    UIGravityBehavior* gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self.exampleContainerView]];
    gravityBehaviour.gravityDirection = CGVectorMake(0.0, 10.0);
    [self.animator addBehavior:gravityBehaviour];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.exampleContainerView]];
    [itemBehaviour addAngularVelocity:-M_PI_2 forItem: self.exampleContainerView];
    [self.animator addBehavior:itemBehaviour];
    
    self.currentExample++;
    
    //show new example
    BAFluidView *nextFluidViewExample = [self nextBAFluidViewExample];
    [nextFluidViewExample addGestureRecognizer:self.gestureRecognizer];
    nextFluidViewExample.alpha = 0.0;
    
    [self.view insertSubview:nextFluidViewExample belowSubview:self.swipeForNextExampleLabel];
    
    [UIView animateWithDuration:0.5 animations:^{
        nextFluidViewExample.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.exampleContainerView removeFromSuperview];
        self.exampleContainerView = nextFluidViewExample;
        self.exampleContainerView.layer.allowsEdgeAntialiasing = YES;
    }];
    
}

-(BAFluidView*) nextBAFluidViewExample {
    BAFluidView *fluidView;
    
    if(self.motionManager){
        //stop motion manager if on
        [self.motionManager stopAccelerometerUpdates];
        self.motionManager = nil;
    }
        
    switch (self.currentExample) {
        case 0://Example with a mask
        {
            
            fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame startElevation:@0.5];
            
            fluidView.fillColor = [UIColor colorWithHex:0x397ebe];
            [fluidView fillTo:@0.9];
            [fluidView startAnimation];
            
            UIImage *maskingImage = [UIImage imageNamed:@"iconImage"];
            CALayer *maskingLayer = [CALayer layer];
            maskingLayer.frame = CGRectMake(CGRectGetMidX(fluidView.frame) - maskingImage.size.width/2, 180, maskingImage.size.width, maskingImage.size.height);
            [maskingLayer setContents:(id)[maskingImage CGImage]];
            [fluidView.layer setMask:maskingLayer];
            [self changeTitleColor:[UIColor colorWithHex:0x2e353d]];
            
            return fluidView;
        }
            
        case 1://example with a fill of the screen
        {
            fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame startElevation:@0.0];
            fluidView.fillColor = [UIColor colorWithHex:0x397ebe];
            fluidView.fillDuration = 3.0;
            [fluidView fillTo:@1.0];
            [fluidView startAnimation];
            [self changeTitleColor:[UIColor whiteColor]];
            return fluidView;
        }
            
        case 2://Example with a different color and stationary
        {
            
            fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame startElevation:@0.5];
            fluidView.strokeColor = [UIColor whiteColor];
            fluidView.fillColor = [UIColor colorWithHex:0x2e353d];
            [fluidView keepStationary];
            [fluidView startAnimation];
            [self changeTitleColor:[UIColor whiteColor]];
            return fluidView;
        }
            
        case 3://Example with clear fill color
        {
            fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame startElevation:@0.5];
            fluidView.fillColor = [UIColor clearColor];
            fluidView.strokeColor = [UIColor whiteColor];
            [fluidView keepStationary];
            [fluidView startAnimation];
            [self changeTitleColor:[UIColor colorWithHex:0x2e353d]];
            return fluidView;
        }
            
        case 4://Example with accelerometer
        {
            self.motionManager = [[CMMotionManager alloc] init];
            
            if (self.motionManager.deviceMotionAvailable) {
                self.motionManager.deviceMotionUpdateInterval = 0.3f;
                [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                                        withHandler:^(CMDeviceMotion *data, NSError *error) {
                                                            NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
                                                            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:
                                                                                      data forKey:@"data"];
                                                            [nc postNotificationName:kBAFluidViewCMMotionUpdate object:self userInfo:userInfo];
                                                        }];
            }
            
            fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame startElevation:@0.5];
            fluidView.strokeColor = [UIColor whiteColor];
            fluidView.fillColor = [UIColor colorWithHex:0x2e353d];
            [fluidView keepStationary];
            [fluidView startAnimation];
            [fluidView startTiltAnimation];
            [self changeTitleColor:[UIColor whiteColor]];
            
            UILabel *tiltLabel = [[UILabel alloc] init];
            tiltLabel.font =[UIFont fontWithName:@"LoveloBlack" size:36];
            tiltLabel.text = @"Tilt Phone!";
            tiltLabel.textColor = [UIColor whiteColor];
            [fluidView addSubview:tiltLabel];
            
            tiltLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [fluidView addConstraint:[NSLayoutConstraint constraintWithItem:tiltLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fluidView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
            [fluidView addConstraint:[NSLayoutConstraint constraintWithItem:tiltLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:fluidView attribute:NSLayoutAttributeTop multiplier:1.0 constant:80]];
            return fluidView;
        }
            
        default:
        {
            self.currentExample = 0;
            return [self nextBAFluidViewExample];
        }
    }
    
    return nil;
}

@end
