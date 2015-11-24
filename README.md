# MUKScrollTrigger

[![CI Status](http://img.shields.io/travis/muccy/MUKScrollTrigger.svg?style=flat)](https://travis-ci.org/muccy/MUKScrollTrigger)
[![Version](https://img.shields.io/cocoapods/v/MUKScrollTrigger.svg?style=flat)](http://cocoadocs.org/docsets/MUKScrollTrigger)
[![License](https://img.shields.io/cocoapods/l/MUKScrollTrigger.svg?style=flat)](http://cocoadocs.org/docsets/MUKScrollTrigger)
[![Platform](https://img.shields.io/cocoapods/p/MUKScrollTrigger.svg?style=flat)](http://cocoadocs.org/docsets/MUKScrollTrigger)

`MUKScrollTrigger` observes a UIScrollView instance and it monitors scrolled amount. When a threshold is passed, it triggers.
This mechanism could be used to achieve infinite scroll of a table view, for example.

## Usage

````objective-c
self.trigger = [[MUKScrollTrigger alloc] initWithScrollView:scrollView test:^(MUKScrollTrigger *trigger) {
	return trigger.scrolledFraction.trailing.height > 0.95f;
}];
[self.trigger addTarget:self action:@selector(scrollTriggerActivated:)];
````

## Requirements

* iOS 7 SDK.
* Minimum deployment target: iOS 7.

## Installation

`MUKScrollTrigger` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "MUKScrollTrigger"

## Author

Marco Muccinelli, muccymac@gmail.com

## License

`MUKScrollTrigger` is available under the MIT license. See the LICENSE file for more info.
