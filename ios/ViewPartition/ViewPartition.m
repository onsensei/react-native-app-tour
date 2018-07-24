//
//  ViewPartition.m
//  RNAppTour
//
//  Created by Thanaphat Suwannikornkul on 24/7/2561 BE.
//  Copyright © 2561 Facebook. All rights reserved.
//

#import "ViewPartition.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static UIView *partitionView;

@implementation ViewPartition

+ (void)initIfNeed {
    if (!partitionView) {
        partitionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
        partitionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        partitionView.userInteractionEnabled = YES;
    }
}

+ (void)showViewPartition {
    [ViewPartition initIfNeed];
    
    UIView *container = UIApplication.sharedApplication.delegate.window;
    bool isShowed = [partitionView isDescendantOfView:container];
    if (!isShowed) {
        [container addSubview:partitionView];
    }
}

+ (void)hideViewPartition {
    [ViewPartition initIfNeed];
    
    UIView *container = UIApplication.sharedApplication.delegate.window;
    bool isShowed = [partitionView isDescendantOfView:container];
    if (isShowed) {
        [partitionView removeFromSuperview];
    }
}

@end
