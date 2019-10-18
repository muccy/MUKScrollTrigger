//
//  ViewController.m
//  Example
//
//  Created by Marco on 24/11/15.
//  Copyright © 2015 MeLive. All rights reserved.
//

#import "ViewController.h"
#import <MUKScrollTrigger/MUKScrollTrigger.h>

static void *const kKVOContext = (void *)&kKVOContext;

@interface ViewController ()
@property (nonatomic) MUKScrollTrigger *scrollTrigger;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollTrigger = [[MUKScrollTrigger alloc] initWithScrollView:self.scrollView test:^BOOL(MUKScrollTrigger * _Nonnull trigger)
    {
        return trigger.scrollableSize.height - trigger.scrolledSize.trailing.height < 44.0f;
    }];
    
    [self.scrollTrigger addTarget:self action:@selector(triggerActivated:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.scrollTrigger addObserver:self forKeyPath:NSStringFromSelector(@selector(scrolledSize)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:kKVOContext];
    [self.scrollTrigger addObserver:self forKeyPath:NSStringFromSelector(@selector(scrolledFraction)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:kKVOContext];
    [self.scrollTrigger addObserver:self forKeyPath:@"active" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:kKVOContext];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.scrollTrigger removeObserver:self forKeyPath:NSStringFromSelector(@selector(scrolledSize)) context:kKVOContext];
    [self.scrollTrigger removeObserver:self forKeyPath:NSStringFromSelector(@selector(scrolledFraction)) context:kKVOContext];
    [self.scrollTrigger removeObserver:self forKeyPath:@"active" context:kKVOContext];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets const insets = UIEdgeInsetsMake([self.topLayoutGuide length], 0.0f, [self.bottomLayoutGuide length], 0.0f);
    if (!UIEdgeInsetsEqualToEdgeInsets(insets, self.scrollView.contentInset)) {
        self.scrollView.contentInset = insets;
        [self.scrollView setContentOffset:CGPointMake(0.0f, -insets.top) animated:NO];
    }
}

- (void)updateStatusLabel {
    self.statusLabel.text = [NSString stringWithFormat:@"Scroll: %@\nFraction: %@\nActive: %@", NSStringFromMUKScrollAmount(self.scrollTrigger.scrolledSize), NSStringFromMUKScrollAmount(self.scrollTrigger.scrolledFraction), self.scrollTrigger.isActive ? @"YES" : @"NO"];
}

- (void)triggerActivated:(MUKScrollTrigger *)trigger {
    self.statusLabel.backgroundColor = [UIColor colorWithRed:(float)arc4random_uniform(255)/255.0 green:(float)arc4random_uniform(255)/255.0 blue:(float)arc4random_uniform(255)/255.0 alpha:0.5f];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &kKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if (object == self.scrollTrigger) {
        [self updateStatusLabel];
    }
}

@end
