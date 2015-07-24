#BAFluidView

[![CI Status](http://img.shields.io/travis/antiguab/BAFluidView.svg?style=flat)](https://travis-ci.org/Bryan Antigua/BAFluidView)
[![Version](https://img.shields.io/cocoapods/v/BAFluidView.svg?style=flat)](http://cocoadocs.org/docsets/BAFluidView)
[![License](https://img.shields.io/cocoapods/l/BAFluidView.svg?style=flat)](http://cocoadocs.org/docsets/BAFluidView)
[![Platform](https://img.shields.io/cocoapods/p/BAFluidView.svg?style=flat)](http://cocoadocs.org/docsets/BAFluidView)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Overview
![example6](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example6.gif)
![example1](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example1.gif)

This view and its layer create a 2D fluid animation that can be used to simulate a filling effect.

<br/>

## Requirements
* Works on any iOS device

<br/>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<br/>

## Getting Started
### Installation

BAFluidView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod "BAFluidView"
```

### Simple Usage


#### Basic
To add a `BAFluidView` to your app, add the line:

```objc
BAFluidView *view = [[BAFluidView alloc] initWithFrame:self.view.frame];
[view fillTo:@1.0];
view.fillColor = [UIColor colorWithHex:0x397ebe];
[view startAnimation];
```

This creates the following view:

![example1](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example1.gif)


### Advanced Usage
Listed below are examples of several properties that you can control. 

#### Init
You can use `initWithFrame:maxAmplitude:minAmplitude:amplitudeIncrement:` to control how high/low you want the wave to go. The increment method helps control the variation between the peaks. If you're only concerned is where the fluid starts, `initWithFrame:(CGRect)aRect startElevation:(NSNumber*)aStartElevation` creates a fluid view with default values, but lets you choose the starting elevation. To control all init values, use the method `(id)initWithFrame:(CGRect)aRect maxAmplitude:(int)aMaxAmplitude minAmplitude:(int)aMinAmplitude amplitudeIncrement:(int)aAmplitudeIncrement startElevation:(NSNumber*)aStartElevation` which is a combination of the two above.


#### Animate Only Once (End in old state)
If you only want the effect to fill only once (or any specific amount of times) you can edit the `fillRepeatCount` property:

```objc
BAFluidView *view = [[BAFluidView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
view.fillRepeatCount = 1;
[view fillTo:@1.0];
view.fillColor = [UIColor colorWithHex:0x397ebe];
[view startAnimation];
```
#### Animate Only Once (End in new state)
You can also create the same effect as above, but stay in the filled state by editing the `fillAutoReverse` property:

```objc
BAFluidView *view = [[BAFluidView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
view.fillColor = [UIColor colorWithHex:0x397ebe];
view.fillAutoReverse = NO;
view.fillRepeatCount = 1;
[view fillTo:@1.0];
[view startAnimation];
```

This creates the following view:

![example2b](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example2b.gif)

#### Fill to specific level

By default, the animation goes to the top of the view. If you don't want it to go the entire distance, you can use the `fillTo:` method by giving it a percentage of the distance you want it to travel:

```objc
BAFluidView *view = [[BAFluidView alloc] initWithFrame:self.view.frame];
[view fillTo:@0.5];
view.fillColor = [UIColor colorWithHex:0x397ebe];
[view startAnimation];
```
This creates the following view:

![example3](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example3.gif)

#### Fill Duration

You can set the duration of a fill with the `fillDuration` property. The duration will be the amount of time it takes for the fill to go from 0% - 100%. Adding it to the example above, we get :

```objc
BAFluidView *view = [[BAFluidView alloc] initWithFrame:self.view.frame];
view.fillDuration = 5.0; 
[view fillTo:@0.5];
view.fillColor = [UIColor colorWithHex:0x397ebe];
[view startAnimation];
```
**Note: `fillDuration` needs to be set before you call `fillTo:` method!**
This creates the following view:

![example3b](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example3b.gif)
#### Fill Color

By editing the `fillColor` property, you can give the fluid any color:

```objc
BAFluidView *fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame startElevation:@0.5];
fluidView.strokeColor = [UIColor whiteColor];
fluidView.fillColor = [UIColor colorWithHex:0x2e353d];
[fluidView keepStationary];
[fluidView startAnimation];
```
**Note: `keepStationary` keeps the fluid at the starting level!**
This creates the following view:

![example4](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example4.gif)

#### Stroke Color

Similiarly, you can alter the stroke property. With a clear `fillColor` you get a wave effect like below:

```objc
BAFluidView *fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame startElevation:@0.5];
fluidView.fillColor = [UIColor clearColor];
fluidView.strokeColor = [UIColor whiteColor];
[fluidView keepStationary];
[fluidView startAnimation];
```

This creates the following view:

![example5](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example5.gif)

#### Use as a Layer

If you want to add the effect to another view, use its layer!

```objc
BAFluidView *fluidView = [[BAFluidView alloc] initWithFrame:self.view.frame startElevation:@0.3];
fluidView.fillColor = [UIColor colorWithHex:0x397ebe];
[fluidView fillTo:@0.9];
[fluidView startAnimation];

UIImage *maskingImage = [UIImage imageNamed:@"icon"];
CALayer *maskingLayer = [CALayer layer];
maskingLayer.frame = CGRectMake(CGRectGetMidX(fluidView.frame) - maskingImage.size.width/2, 70, maskingImage.size.width, maskingImage.size.height);
[maskingLayer setContents:(id)[maskingImage CGImage]];
[fluidView.layer setMask:maskingLayer];
```

Sweet! check it out:

![example6](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example6.gif)



## Author

Bryan Antigua, antigua.B@gmail.com - [bryanantigua.com](bryanantigua.com)


## License

BAFluidView is available under the MIT license. See the LICENSE file for more info.



