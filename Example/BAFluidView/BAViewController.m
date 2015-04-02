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
#define UIColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface BAViewController ()
{
    UIDynamicAnimator *animator;
    UIAttachmentBehavior *attachmentBehavior;
    NSMutableArray *examplesArray;
    UIPanGestureRecognizer *gestureRecognizer;
    CABasicAnimation *fadeIn;
    CABasicAnimation *fadeOut;
    UIView *container;
    int currentExample;
    BOOL activity;
    NSTimer *timer;

}

@end

@implementation BAViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    currentExample = 0;
    container = [self viewWithExample];
    [container addGestureRecognizer:gestureRecognizer];
    [self.view insertSubview:container belowSubview:self.swipeForNextExampleLabel];
    [self setUpBackground];
    activity = NO;
    
    fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.duration = 2.0;
    fadeIn.fromValue = @0.0f;
    fadeIn.toValue = @1.0f;
    fadeIn.removedOnCompletion = NO;
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.additive = NO;
    
    fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.duration = 0.5f;
    fadeOut.fromValue = @1.0f;
    fadeOut.toValue = @0.0f;
    fadeOut.removedOnCompletion = NO;
    fadeOut.fillMode = kCAFillModeForwards;
    fadeOut.additive = NO;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(showSwipeForNextExampleLabel)
                                   userInfo:nil
                                    repeats:YES];

}

-(void)showSwipeForNextExampleLabel{
    //call to action in case user doesn't swipe
    if (!activity) {
        [self stopTimer];
        [self.swipeForNextExampleLabel.layer removeAllAnimations];
        self.swipeForNextExampleLabel.layer.opacity = 1;
        [self.swipeForNextExampleLabel.layer addAnimation:fadeIn forKey:@"fadeIn"];
    }

}

-(void)hideSwipeForNextExampleLabel{
    [self.swipeForNextExampleLabel.layer removeAllAnimations];
    self.swipeForNextExampleLabel.layer.opacity = 0;
    [self.swipeForNextExampleLabel.layer addAnimation:fadeOut forKey:@"fadeOut"];
}

-(void)startTimer{
    if(timer != nil){
        [timer invalidate];
        timer = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                             target:self
                                           selector:@selector(showSwipeForNextExampleLabel)
                                           userInfo:nil
                                            repeats:YES];
}

-(void)stopTimer{
    [timer invalidate];
    timer = nil;
}


-(void) setUpBackground {
    //sets up the green background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromHex(0x53cf84) CGColor],(id)[UIColorFromHex(0x53cf84) CGColor], (id)[UIColorFromHex(0x2aa581) CGColor], (id)[UIColorFromHex(0x1b9680) CGColor], nil];
    gradient.locations = @[[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:0.5f],[NSNumber numberWithFloat:0.8f], [NSNumber numberWithFloat:1.0f]];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:gradient atIndex:0];
}
-(void)panDetected:(UIPanGestureRecognizer*) gesture {
    
        CGPoint locationInContainer = [gesture locationInView:gesture.view];
        CGPoint locationinSuperView = [gesture locationInView:self.view];
    
        if (gesture.state == UIGestureRecognizerStateBegan) {
            //assign the attachment behavior as the view is starting to move
            [animator removeAllBehaviors];
            UIOffset offset = UIOffsetMake(locationInContainer.x - CGRectGetMidX(container.bounds), locationInContainer.y - CGRectGetMidY(container.bounds));
            attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:container offsetFromCenter:offset attachedToAnchor:locationinSuperView];
            [animator addBehavior:attachmentBehavior];

        }
    
        else if (gesture.state == UIGestureRecognizerStateChanged) {
            //update based on where finger is
            attachmentBehavior.anchorPoint = locationinSuperView;
            activity = YES;

        }
    
        else if (gesture.state == UIGestureRecognizerStateEnded) {
            //transition to the next example if swiped down far enough
            [animator removeAllBehaviors];
            UISnapBehavior *snapBehavior =[[UISnapBehavior alloc] initWithItem:container snapToPoint:self.view.center];
            [animator addBehavior:snapBehavior];
            
            if([gesture translationInView:self.view].y > 150 ) {
                [self transitionToNextExample];
            }
        }
}

-(UIView*) viewWithExample {
    BAFluidView *fluidView;

    switch (currentExample) {
        case 0://Example with a mask
        {
            //TO DO add feature to pic a starting elevation
            CGRect frame = self.view.frame;
            frame.origin.y += 40;
            fluidView = [[BAFluidView alloc] initWithFrame:frame];
            fluidView.fillColor = UIColorFromHex(0x397ebe);
            UIImage *maskingImage = [UIImage imageNamed:@"icon"];
            CALayer *maskingLayer = [CALayer layer];
         
            maskingLayer.frame = CGRectMake(CGRectGetMidX(fluidView.frame) - maskingImage.size.width/2, 70, maskingImage.size.width, maskingImage.size.height);
            [maskingLayer setContents:(id)[maskingImage CGImage]];
            [fluidView.layer setMask:maskingLayer];
            [self changeTitleColor:UIColorFromHex(0x2e353d)];
            return fluidView;
        }
            
        case 1://example with a fill of the screen
            fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame];
            fluidView.fillColor = UIColorFromHex(0x397ebe);
            [self changeTitleColor:[UIColor whiteColor]];
            return fluidView;
            
        case 2://Example with a different color and stationary
            fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
            fluidView.fillColor = UIColorFromHex(0x2e353d);
            [fluidView fillTo:0.0]; //don't move
            [self changeTitleColor:[UIColor whiteColor]];
            return fluidView;
            
        case 3://Example with clear fill color
            fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
            fluidView.fillColor = [UIColor clearColor];
            fluidView.strokeColor = [UIColor whiteColor];
            [fluidView fillTo:0.0]; //don't move
            [self changeTitleColor:UIColorFromHex(0x2e353d)];
            return fluidView;
        default:
            currentExample = 0;
            return [self viewWithExample];
    }
    
    return nil;
}

-(void)changeTitleColor:(UIColor*)color{
    
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
    activity = NO;
    [animator removeAllBehaviors];
    
    UIGravityBehavior* gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[container]];
    gravityBehaviour.gravityDirection = CGVectorMake(0.0, 10.0);
    [animator addBehavior:gravityBehaviour];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[container]];
    [itemBehaviour addAngularVelocity:-M_PI_2 forItem: container];
    [animator addBehavior:itemBehaviour];
    
    currentExample++;
    UIView *newContainer = [self viewWithExample];
    [newContainer addGestureRecognizer:gestureRecognizer];
    newContainer.alpha = 0.0;
    [self.view insertSubview:newContainer belowSubview:self.swipeForNextExampleLabel];

    [UIView animateWithDuration:0.5 animations:^{
        newContainer.alpha = 1.0;
    } completion:^(BOOL finished) {
        container = newContainer;
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
