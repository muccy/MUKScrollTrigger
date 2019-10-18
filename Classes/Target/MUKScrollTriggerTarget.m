//
//  MUKScrollTriggerTarget.m
//  
//
//  Created by Marco Muccinelli on 18/10/2019.
//

#import "MUKScrollTriggerTarget.h"

@implementation MUKScrollTriggerTarget

- (instancetype)initWithObject:(id)object action:(SEL)action {
    self = [super init];
    if (self) {
        _object = object;
        _action = action;
    }
    
    return self;
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
