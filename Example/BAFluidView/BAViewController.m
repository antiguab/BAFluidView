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

@interface BAViewController ()

@end

@implementation BAViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //    1. Basic
    BAFluidView *view = [[BAFluidView alloc] initWithFrame:self.view.frame];
    
    
    //    2.a Animate Only Once (End in old state)
//        BAFluidFillView *view = [[BAFluidFillView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
//        view.fillRepeatCount = 1;
    
    //    2.b. Animate Only Once (End in new state)
    //    BAFluidFillView *view = [[BAFluidFillView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
    //    view.fillAutoReverse = NO;
    //    view.fillRepeatCount = 1;
    
    //    3. Fill to specific level
//        BAFluidFillView *view = [[BAFluidFillView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
//        [view fillTo:0.5];
    
    //    4. Fill Color
    //        BAFluidFillView *view = [[BAFluidFillView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
//        view.fillColor = [UIColor blackColor];
    
    
    //    5. Stroke Color
//        BAFluidFillView *view = [[BAFluidFillView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
//        view.fillColor = [UIColor clearColor];
//        view.strokeColor = [UIColor blackColor];
//        [view fillTo:0.0]; //don't move
//    
    
    //    6. Using in a button
//        UIButton *button = [[UIButton alloc] init];
//        button.frame = CGRectMake(self.view.center.x, self.view.center.y, 300, 300);
//        button.layer.anchorPoint = CGPointMake(0.5, 0.5);
//        button.layer.position = CGPointMake(self.view.center.x, self.view.center.y);
//        button.layer.cornerRadius = button.frame.size.height/2;
//        button.clipsToBounds = YES;
//        [button.layer addSublayer:view.layer];
    
    //    For examples 1 - 5 uncomment this line
    [self.view addSubview:view];
    
    //    For examples 6 uncomment this line
//        [self.view addSubview:button];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
