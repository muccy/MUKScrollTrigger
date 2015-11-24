//
//  MUKScrollTrigger.h
//  
//
//  Created by Marco on 24/11/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKScrollTrigger : NSObject
/// Observed scroll view
@property (nonatomic, readonly) UIScrollView *scrollView;
/// Amount scrolled
@property (nonatomic, readonly)

- (instancetype)initWithScrollView:(UIScrollView *)scrollView NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
