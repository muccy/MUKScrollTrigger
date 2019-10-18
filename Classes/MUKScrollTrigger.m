//
//  MUKScrollTrigger.m
//  
//
//  Created by Marco on 24/11/15.
//
//

#import "MUKScrollTrigger.h"
#import "MUKScrollTriggerTarget.h"

#define DEBUG_LOG_SCROLLED_SIZE     0
#define DEBUG_LOG_SCROLLED_FRACTION 0
#define DEBUG_LOG_ACTIVE            0

static void *const kKVOContext = (void *)&kKVOContext;

@interface MUKScrollTrigger ()
@property (nonatomic, readwrite) MUKScrollAmount scrolledSize, scrolledFraction;
@property (nonatomic, readwrite, getter=isActive) BOOL active;

@property (nonatomic, readonly, copy, nonnull) BOOL (^triggerTest)(MUKScrollTrigger * _Nonnull trigger);
@property (nonatomic, readwrite, copy, nullable) NSSet<MUKScrollTriggerTarget *> *targets;
@property (nonatomic) BOOL isObservingScrollView;
@end

@implementation MUKScrollTrigger

- (void)dealloc {
    [self unobserveScrollView];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView test:(BOOL (^ _Nonnull)(MUKScrollTrigger * _Nonnull))triggerTest
{
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _triggerTest = [triggerTest copy];
        
        [self updateScrolledSize];
        [self observeScrollView];
    }
    
    return self;
}

- (void)addTarget:(id)targetObject action:(SEL)action {
    MUKScrollTriggerTarget *const target = [[MUKScrollTriggerTarget alloc] initWithObject:targetObject action:action];
    self.targets = [self.targets ?: [NSSet set] setByAddingObject:target];
}

- (void)removeTarget:(id)targetObject {
    NSMutableSet<MUKScrollTriggerTarget *> *const targets = [self.targets mutableCopy] ?: [NSMutableSet set];
    
    for (MUKScrollTriggerTarget *target in self.targets) {
        if ([target.object isEqual:targetObject]) {
            [targets removeObject:target];
        }
    } // for
    
    self.targets = targets;
}

#pragma mark - Accessors

- (void)setScrolledSize:(MUKScrollAmount)scrolledSize {
    _scrolledSize = scrolledSize;
    [self updateScrolledFractionWithScrolledSize:scrolledSize];
    [self updateActive];
}

- (void)setActive:(BOOL)active {
    if (active != _active) {
        _active = active;
        
        // Call targets on activation
        if (active) {
            for (MUKScrollTriggerTarget *target in self.targets) {
                [target performWithSender:self];
            }
        }
    }
}

- (CGSize)scrollableSize {
    UIScrollView *const scrollView = self.scrollView;
    return CGSizeMake(scrollView.contentSize.width - scrollView.contentInset.left - scrollView.contentInset.right, scrollView.contentSize.height - scrollView.contentInset.top - scrollView.contentInset.bottom);
}

#pragma mark - Overrides

- (instancetype)init {
    NSAssert(NO, @"Use designated initializer");
    return [self initWithScrollView:[UIScrollView new] test:^(MUKScrollTrigger *trigger) { return NO; }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &kKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if (object == self.scrollView) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(bounds))]) {
            [self updateScrolledSize];
        }
        else if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            [self updateScrolledFractionWithScrolledSize:self.scrolledSize];
        }
    }
}

#pragma mark - Private — Observations

- (void)observeScrollView {
    if (!self.isObservingScrollView) {
        [self.scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) options:NSKeyValueObservingOptionNew context:kKVOContext];
        [self.scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew context:kKVOContext];
        self.isObservingScrollView = YES;
    }
}

- (void)unobserveScrollView {
    if (self.isObservingScrollView) {
        [self.scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) context:kKVOContext];
        [self.scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:kKVOContext];
        self.isObservingScrollView = NO;
    }
}

#pragma mark - Private — Updates

- (void)updateScrolledSize {
    self.scrolledSize = ({
        UIScrollView *const scrollView = self.scrollView;

        CGFloat const leadingWidth = scrollView.contentOffset.x + scrollView.contentInset.left;
        CGFloat const leadingHeight = scrollView.contentOffset.y + scrollView.contentInset.top;
        CGFloat const trailingWidth = scrollView.contentOffset.x + CGRectGetWidth(scrollView.bounds) - scrollView.contentInset.left - scrollView.contentInset.right;
        CGFloat const trailingHeight = scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) - scrollView.contentInset.top - scrollView.contentInset.bottom;
        
        MUKScrollAmountMake(leadingWidth, leadingHeight, trailingWidth, trailingHeight);
    });
    
#if DEBUG_LOG_SCROLLED_SIZE
    NSLog(@"Scrolled size: %@", NSStringFromMUKScrollAmount(self.scrolledSize));
#endif
}

- (void)updateScrolledFractionWithScrolledSize:(MUKScrollAmount)scrolledSize {
    self.scrolledFraction = ({
        CGSize const scrollableSize = self.scrollableSize;
        
        CGFloat const leadingWidth = scrolledSize.leading.width/scrollableSize.width;
        CGFloat const leadingHeight = scrolledSize.leading.height/scrollableSize.height;
        CGFloat const trailingWidth = scrolledSize.trailing.width/scrollableSize.width;
        CGFloat const trailingHeight = scrolledSize.trailing.height/scrollableSize.height;
        
        MUKScrollAmountMake(leadingWidth, leadingHeight, trailingWidth, trailingHeight);
    });
    
#if DEBUG_LOG_SCROLLED_FRACTION
    NSLog(@"Scrolled fraction: %@", NSStringFromMUKScrollAmount(self.scrolledFraction));
#endif
}

- (void)updateActive {
    BOOL const triggered = self.triggerTest(self);
    
    if (self.isActive) {
        // Already active: can only deactivate
        if (!triggered) {
            self.active = NO;
#if DEBUG_LOG_ACTIVE
            NSLog(@"Scroll trigger deactivated");
#endif
        }
    }
    else {
        // Not active: can only activate
        if (triggered) {
            self.active = YES;
#if DEBUG_LOG_ACTIVE
            NSLog(@"Scroll trigger activated");
#endif
        }
    }
}

#pragma mark - Private — Scroll Amount

inline MUKScrollAmount MUKScrollAmountMake(CGFloat leadingWidth, CGFloat leadingHeight, CGFloat trailingWidth, CGFloat trailingHeight)
{
    return (MUKScrollAmount){ CGSizeMake(leadingWidth, leadingHeight), CGSizeMake(trailingWidth, trailingHeight) };
}

inline NSString * _Nonnull NSStringFromMUKScrollAmount(MUKScrollAmount amount) {
    return [NSString stringWithFormat:@"{ MIN=%@, MAX=%@ }", NSStringFromCGSize(amount.leading), NSStringFromCGSize(amount.trailing)];
}

@end
