//
//  MUKScrollTrigger.m
//  
//
//  Created by Marco on 24/11/15.
//
//

#import "MUKScrollTrigger.h"
#import <KVOController/FBKVOController.h>

#define DEBUG_LOG_SCROLLED_SIZE     0
#define DEBUG_LOG_SCROLLED_FRACTION 0
#define DEBUG_LOG_ACTIVE            0

NS_ASSUME_NONNULL_BEGIN
@interface MUKScrollTriggerTarget : NSObject
@property (nonatomic, weak, readonly) id object;
@property (nonatomic, readonly) SEL action;

- (instancetype)initWithObject:(id)object action:(SEL)action NS_DESIGNATED_INITIALIZER;
- (void)performWithSender:(MUKScrollTrigger *)sender;

- (BOOL)isEqualToScrollTriggerTarget:(MUKScrollTriggerTarget *)target;
@end
NS_ASSUME_NONNULL_END

@implementation MUKScrollTriggerTarget

- (instancetype)initWithObject:(id)object action:(SEL)action {
    self = [super init];
    if (self) {
        _object = object;
        _action = action;
    }
    
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"Use designated initializer");
    return [self initWithObject:[NSObject new] action:@selector(description)];
}

- (void)performWithSender:(MUKScrollTrigger *)sender {
    if ([self.object respondsToSelector:self.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.object performSelector:self.action withObject:sender];
#pragma clang diagnostic pop
    }
}

- (BOOL)isEqualToScrollTriggerTarget:(MUKScrollTriggerTarget *)target {
    BOOL const sameTargetObject = (!self.object && !target.object) || [self.object isEqual:target.object];
    BOOL const sameAction = self.action == target.action;
    
    return sameTargetObject && sameAction;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToScrollTriggerTarget:object];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return 3853 ^ [self.object hash];
}

@end

#pragma mark -

@interface MUKScrollTrigger ()
@property (nonatomic, readwrite) MUKScrollAmount scrolledSize, scrolledFraction;
@property (nonatomic, readwrite, getter=isActive) BOOL active;

@property (nonatomic, readonly, copy, nonnull) BOOL (^triggerTest)(MUKScrollTrigger * _Nonnull trigger);
@property (nonatomic, readwrite, copy, nullable) NSSet<MUKScrollTriggerTarget *> *targets;
@end

@implementation MUKScrollTrigger

- (instancetype)initWithScrollView:(UIScrollView *)scrollView test:(BOOL (^ _Nonnull)(MUKScrollTrigger * _Nonnull))triggerTest
{
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _triggerTest = [triggerTest copy];
        
        [self updateScrolledSize];
        [self observeScrollViewBounds];
        [self observeScrollViewContentSize];
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

#pragma mark - Private — Observations

- (void)observeScrollViewBounds {
    [self.KVOController observe:self.scrollView keyPath:NSStringFromSelector(@selector(bounds)) options:NSKeyValueObservingOptionNew block:^(MUKScrollTrigger *observer, UIScrollView *object, NSDictionary *change)
    {
        [observer updateScrolledSize];
    }];
}

- (void)observeScrollViewContentSize {
    [self.KVOController observe:self.scrollView keyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew block:^(MUKScrollTrigger *observer, UIScrollView *object, NSDictionary *change)
    {
        [observer updateScrolledFractionWithScrolledSize:observer.scrolledSize];
    }];
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
