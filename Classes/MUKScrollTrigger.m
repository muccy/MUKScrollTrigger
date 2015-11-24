//
//  MUKScrollTrigger.m
//  
//
//  Created by Marco on 24/11/15.
//
//

#import "MUKScrollTrigger.h"
#import <KVOController/FBKVOController.h>

#define DEBUG_LOG   0

@implementation MUKScrollTrigger

#pragma mark - Private — Observations

- (void)observeScrollViewBounds {
    [self.KVOController observe:self.scrollView keyPath:NSStringFromSelector(@selector(bounds)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKScrollTrigger *observer, UIScrollView *object, NSDictionary *change)
    {
        [observer updateTriggered];
    }];
}

- (void)observeScrollViewContentSize {
    [self.KVOController observe:self.scrollView keyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKScrollTrigger *observer, UIScrollView *object, NSDictionary *change)
    {
        [observer updateTriggered];
    }];
}

@end
