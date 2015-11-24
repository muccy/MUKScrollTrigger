//
//  ViewController.m
//  Example
//
//  Created by Marco on 24/11/15.
//  Copyright © 2015 MeLive. All rights reserved.
//

#import "ViewController.h"
#import <MUKScrollTrigger/MUKScrollTrigger.h>
#import <KVOController/FBKVOController.h>

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
    
    [self.KVOController observe:self.scrollTrigger keyPath:NSStringFromSelector(@selector(scrolledSize)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(ViewController *observer, id object, NSDictionary *change)
    {
        [observer updateStatusLabel];
    }];
    
    [self.KVOController observe:self.scrollTrigger keyPath:NSStringFromSelector(@selector(scrolledFraction)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(ViewController *observer, id object, NSDictionary *change)
    {
        [observer updateStatusLabel];
    }];
    
    [self.KVOController observe:self.scrollTrigger keyPath:@"active" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(ViewController *observer, id object, NSDictionary *change)
    {
        [observer updateStatusLabel];
    }];
    
    [self.scrollTrigger addTarget:self action:@selector(triggerActivated:)];
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

@end
