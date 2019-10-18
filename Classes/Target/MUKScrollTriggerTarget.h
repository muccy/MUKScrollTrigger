//
//  MUKScrollTriggerTarget.h
//  
//
//  Created by Marco Muccinelli on 18/10/2019.
//

#import <Foundation/Foundation.h>
#import <MUKScrollTrigger/MUKScrollTrigger.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKScrollTriggerTarget : NSObject
@property (nonatomic, weak, readonly) id object;
@property (nonatomic, readonly) SEL action;

- (instancetype)initWithObject:(id)object action:(SEL)action NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)performWithSender:(MUKScrollTrigger *)sender;
- (BOOL)isEqualToScrollTriggerTarget:(MUKScrollTriggerTarget *)target;
@end

NS_ASSUME_NONNULL_END
