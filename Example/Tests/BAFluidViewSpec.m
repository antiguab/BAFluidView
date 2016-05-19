//The MIT License (MIT)
//
//Copyright (c) 2016 Bryan Antigua <antigua.b@gmail.com>
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

#import "UIColor+ColorWithHex.h"
#import "BAFluidView.h"

SpecBegin(BAFluidView)


describe(@"BAFluidView Logical Tests", ^{
    __block BAFluidView *fluidView;
    
    beforeEach(^{
        fluidView = [[BAFluidView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    
    
    it(@"should be created and have default properties", ^{
        expect(fluidView).toNot.beNil();
        expect(fluidView).to.beInstanceOf([BAFluidView class]);
        expect(fluidView.fillAutoReverse).to.beTruthy();
        expect(fluidView.fillRepeatCount).to.equal(HUGE_VALF);
        expect(fluidView.amplitudeIncrement).to.equal(5);
        expect(fluidView.maxAmplitude).to.equal(40);
        expect(fluidView.minAmplitude).to.equal(5);
        expect(fluidView.fillDuration).to.equal(7.0);
    });
    
    it(@"should change the fillColor Property", ^{
        fluidView.fillColor = [UIColor blackColor];
        expect(fluidView.fillColor).to.equal([UIColor blackColor]);
    });
    
    it(@"should change the strokeColor Property", ^{
        fluidView.strokeColor = [UIColor blackColor];
        expect(fluidView.strokeColor).to.equal([UIColor blackColor]);
    });
    
    
    it(@"should change the fillRepeatCount Property", ^{
        fluidView.fillRepeatCount = 3;
        expect(fluidView.fillRepeatCount).to.equal(3);
    });
    
    it(@"should change the lineWidth Property", ^{
        fluidView.lineWidth = 3;
        expect(fluidView.lineWidth).to.equal(3);
    });
    
    it(@"should change the fillAutoReverse Property", ^{
        fluidView.fillAutoReverse = NO;
        expect(fluidView.fillAutoReverse).to.equal(NO);
    });

    it(@"should change the fillDuration Property", ^{
        fluidView.fillDuration = 5.0;
        expect(fluidView.fillDuration).to.equal(5.0);
    });

    it(@"should change the amplitudeINcrement Property", ^{
        fluidView.amplitudeIncrement = 2.0;
        expect(fluidView.amplitudeIncrement).to.equal(2.0);
    });
    
    it(@"should change the maxAmplitude Property", ^{
        fluidView.maxAmplitude = 60.0;
        expect(fluidView.maxAmplitude).to.equal(60.0);
    });

    it(@"should change the minAmplitude Property", ^{
        fluidView.minAmplitude = 10.0;
        expect(fluidView.minAmplitude).to.equal(10.0);
    });
    
    it(@"should be created with init function and have default properties", ^{
        fluidView = [[BAFluidView alloc] initWithFrame:[UIScreen mainScreen].bounds maxAmplitude:60 minAmplitude:10 amplitudeIncrement:15];
        expect(fluidView).toNot.beNil();
        expect(fluidView).to.beInstanceOf([BAFluidView class]);
        expect(fluidView.amplitudeIncrement).to.equal(15);
        expect(fluidView.maxAmplitude).to.equal(60);
        expect(fluidView.minAmplitude).to.equal(10);
    });
    
    it(@"should be created with init function and have default properties", ^{
        fluidView = [[BAFluidView alloc] initWithFrame:[UIScreen mainScreen].bounds maxAmplitude:60 minAmplitude:10 amplitudeIncrement:15 startElevation:@0.5];
        expect(fluidView).toNot.beNil();
        expect(fluidView).to.beInstanceOf([BAFluidView class]);
        expect(fluidView.amplitudeIncrement).to.equal(15);
        expect(fluidView.maxAmplitude).to.equal(60);
        expect(fluidView.minAmplitude).to.equal(10);
    });
    
    
    
    it(@"should be created with init function and have default properties", ^{
        fluidView = [[BAFluidView alloc] initWithFrame:[UIScreen mainScreen].bounds startElevation:@0.5];
        expect(fluidView).toNot.beNil();
        expect(fluidView).to.beInstanceOf([BAFluidView class]);
        expect(fluidView.amplitudeIncrement).to.equal(5);
        expect(fluidView.maxAmplitude).to.equal(40);
        expect(fluidView.minAmplitude).to.equal(5);
    });
    
    it(@"should change the properties to keep the fluid stationary", ^{
        [fluidView keepStationary];
        expect(fluidView.fillRepeatCount).to.equal(0);
        expect(fluidView.fillAutoReverse).to.equal(NO);
    });
    
    afterEach(^{
        fluidView = nil;
    });
});

SpecEnd