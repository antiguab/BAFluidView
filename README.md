#BAFluidView

[![CI Status](http://img.shields.io/travis/antiguab/BAFluidView.svg?style=flat)](https://travis-ci.org/Bryan Antigua/BAFluidView)
[![Version](https://img.shields.io/cocoapods/v/BAFluidView.svg?style=flat)](http://cocoadocs.org/docsets/BAFluidView)
[![License](https://img.shields.io/cocoapods/l/BAFluidView.svg?style=flat)](http://cocoadocs.org/docsets/BAFluidView)
[![Platform](https://img.shields.io/cocoapods/p/BAFluidView.svg?style=flat)](http://cocoadocs.org/docsets/BAFluidView)

## Overview
![example6](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example6.gif)
![example1](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example1.gif)

This view and it's layer create a 2D fluid animation that can be used to simulate a filling effect.

<br/>

## Requirements
* Works on any iOS device, but is limited to iOS 8.0 or higher

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
The simplest way to add a BAFluidView to your app is by adding the line:

```
BAFluidFillView *view = [[BAFluidFillView alloc] initWithFrame:self.view.frame];
[self.view addSubview:view];
```

This creates the following view:

![example1](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example1.gif)


### Advanced Usage
There are several properties that you can control, and the examples are listed below. They also all use a different initialization method called
initWithFrame:maxAmplitude:minAmplitude:amplitudeIncrement:. This init method lets you control how high/low you want the wave to go. The increment method helps control the variation between the peaks.

#### Animate Only Once (End in old state)
If you only want the effect to fill only once (or any specific amount of times) you can edit the fillRepeatCount property:

```
BAFluidFillView *view = [[BAFluidFillView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
view.fillRepeatCount = 1;
```
#### Animate Only Once (End in new state)
You can also create the same effect as above, but stay in the filled state by editing the fillAutoReverse property:

```
BAFluidFillView *view = [[BAFluidFillView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
view.fillAutoReverse = NO;
view.fillRepeatCount = 1;
```

This creates the following view:

![example2b](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example2b.gif)

#### Fill to specific level

By default, the animation goes to the top of the view. If you don't want it to go the entire distance, you can use the **fillTo:** method by giving it a percentage of the distance you want it to travel:

```
BAFluidFillView *view = [[BAFluidFillView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
[view fillTo:0.5];
```
**Note: Using fillTo:0 creates a stationary elevation! 

This creates the following view:

![example3](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example3.gif)

#### Fill Color

By editing the fillColor property, you can give the fluid any color:

```
BAFluidFillView *view = [[BAFluidFillView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
view.fillColor = [UIColor blackColor];
```

This creates the following view:

![example4](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example4.gif)

#### Stroke Color

Similiarly, you can alter the stroke property. With a clear fillColor you get a wave effect like below:

```
BAFluidFillView *view = [[BAFluidFillView alloc] initWithFrame:self.view.frame maxAmplitude:40 minAmplitude:5 amplitudeIncrement:5];
view.fillColor = [UIColor clearColor];
view.strokeColor = [UIColor blackColor];
[view fillTo:0.0]; //don't move
```

This creates the following view:

![example5](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example5.gif)

#### Use as a Layer 

If you want to add the effect to another view, simply use it's layer. In the example below, we use it on a button!

```
UIButton *button = [[UIButton alloc] init];
button.frame = CGRectMake(self.view.center.x, self.view.center.y, 300, 300);
button.layer.anchorPoint = CGPointMake(0.5, 0.5);
button.layer.position = CGPointMake(self.view.center.x, self.view.center.y);
button.layer.cornerRadius = button.frame.size.height/2;
button.clipsToBounds = YES;
[button.layer addSublayer:view.layer];
[self.view addSubview:button];
```

Sweet check it out:

![example6](https://github.com/antiguab/BAFluidView/blob/master/readmeAssets/example6.gif)



## Author

Bryan Antigua, antigua.B@gmail.com


## License

BAFluidView is available under the MIT license. See the LICENSE file for more info.



