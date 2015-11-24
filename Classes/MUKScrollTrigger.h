//
//  MUKScrollTrigger.h
//  
//
//  Created by Marco on 24/11/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    /**
     Amount scrolled measured at the minimum point (e.g.: in a vertical list
     leading scrolled height is zero at beginning because it is calculated at
     top-left corner)
     */
    CGSize leading;
    /**
     Amount scrolled measured at the maximum point (e.g.: in a vertical list
     trailing scrolled height is not zero at beginning because it is calculated at
     bottom-right corner)
     */
    CGSize trailing;
} MUKScrollAmount;

/// @returns New scroll amount value
extern inline MUKScrollAmount MUKScrollAmountMake(CGFloat leadingWidth, CGFloat leadingHeight, CGFloat trailingWidth, CGFloat trailingHeight);
/// @returns String representation of scroll amount
extern inline NSString * _Nonnull NSStringFromMUKScrollAmount(MUKScrollAmount amount);

/**
 */
@interface MUKScrollTrigger : NSObject
/// Observed scroll view
@property (nonatomic, readonly) UIScrollView *scrollView;
/// Scrolled amount in points
@property (nonatomic, readonly) MUKScrollAmount scrolledSize;
/**
 Scrolled amount in fraction
 @warning This value may change during scrolling because contentSize could be
 changed by some UIScrollView subclasses (e.g: UITextView, UITableView). You can
 minimize the impact of this issue by testing high values of scrolledFraction to
 activate the trigger (values over 0.95 should be ok).
 */
@property (nonatomic, readonly) MUKScrollAmount scrolledFraction;
/**
 Content size without content inset.
 @warning This value may change during scrolling because contentSize could be
 changed by some UIScrollView subclasses (e.g: UITextView, UITableView).
 */
@property (nonatomic, readonly) CGSize scrollableSize;
/// When this property is set to YES, target actions are fired
@property (nonatomic, readonly, getter=isActive) BOOL active;

/**
 Designated initializer
 @param scrollView      Scroll view to observe
 @param triggerTest     A block called everytime scrollView is scrolled. If the
                        block returns YES and self.active is NO, self.active is 
                        set to YES. You should keep this block as responsive as
                        you can, because it will be called very very ofter (at
                        each scroll step).
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView test:(BOOL (^ _Nonnull)(MUKScrollTrigger * _Nonnull trigger))triggerTest NS_DESIGNATED_INITIALIZER;

/**
 Add target to be called when trigger is activated
 @param target  Target to be called when trigger is activated. Please note that
                this object is not retained
 @param action  Selector called on target. It could take a parameter which will
                be the sender.
 */
- (void)addTarget:(id)target action:(SEL)action;
/// Remove a target
- (void)removeTarget:(id)target;
@end

NS_ASSUME_NONNULL_END
