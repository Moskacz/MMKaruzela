//
//  MMSegmentedControl.m
//  MMKaruzela
//
//  Created by Michał Moskała on 29.08.2014.
//  Copyright (c) 2014 Miquido. All rights reserved.
//

#import "MMSegmentedControl.h"

@interface MMSegmentedControl()

@property (nonatomic, strong) NSArray *horizontalConstraints;
@property (nonatomic, strong) NSLayoutConstraint *horizontalCenter;

@end

@implementation MMSegmentedControl

- (void)updateConstraints {
    [super updateConstraints];
    [self removeConstraints:self.constraints];
    if (self.horizontalConstraints)
        [self.superview removeConstraints:self.horizontalConstraints];
    if (self.horizontalCenter) {
        [self.superview removeConstraint:self.horizontalCenter];
    }
    
    [self setupBaseConstraints];
    
    if ([self fitInSuperView]) {
        self.horizontalCenter = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        [self.superview addConstraint:self.horizontalCenter];
    } else {
        [self.superview addConstraints:self.horizontalConstraints];
    }
}

- (void)setupBaseConstraints {
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(28)]" options:0 metrics:nil views:@{@"self":self}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(523)]" options:0 metrics:nil views:@{@"self":self}]];
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[self]" options:0 metrics:nil views:@{@"self":self}]];
}

- (NSArray *)horizontalConstraints {
    if (!_horizontalConstraints) {
        if ([self isFirstElementSelected]) {
            _horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[self]" options:0 metrics:nil views:@{@"self":self}];
        } else if ([self isLastElementSelected]) {
            _horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[self]-10-|" options:0 metrics:nil views:@{@"self":self}];
        }
    }
    return _horizontalConstraints;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    [[self sortedArrayByFrameOrigin] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint(view.frame, locationPoint)) {
            if (idx != self.selectedSegmentIndex)
                self.selectedSegmentIndex = idx;
        }
    }];
}

- (NSArray *)sortedArrayByFrameOrigin {
    return [self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *first, UIView *second) {
        if (first.frame.origin.x == second.frame.origin.x)
            return NSOrderedSame;
        return (first.frame.origin.x < second.frame.origin.x) ? NSOrderedAscending : NSOrderedDescending;
    }];
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {    
    [super setSelectedSegmentIndex:selectedSegmentIndex];
    if ([self fitInSuperView] == NO) {
        [self changeFrameToCenterSelectedIndex:selectedSegmentIndex];
    }
}

- (BOOL)isFirstElementSelected {
    return self.selectedSegmentIndex == 0;
}

- (BOOL)isLastElementSelected {
    return self.selectedSegmentIndex == self.numberOfSegments - 1;
}

- (BOOL)fitInSuperView {
    return self.superview.bounds.size.width > self.bounds.size.width;
}

- (void)changeFrameToCenterSelectedIndex:(NSUInteger)index {
    CGPoint newFrameOrigin = [self segmentedControlFrameOriginForSelectedIndex:index];
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = CGRectMake(newFrameOrigin.x, newFrameOrigin.y, self.bounds.size.width, self.bounds.size.height);
    }];
}

- (CGFloat)superViewHorizontalCenter {
    return self.superview.bounds.size.width/2.0f;
}

- (CGPoint)segmentedControlFrameOriginForSelectedIndex:(NSUInteger)index {
    NSUInteger selectedIndex = index;
    CGFloat offset = 0.0f;
    for (NSUInteger index = 0; index < selectedIndex; index++) {
        UIView *segment = self.subviews[index];
        offset += segment.bounds.size.width;
    }
    UIView *selectedSegment = self.subviews[selectedIndex];
    offset += selectedSegment.bounds.size.width/2.0f;
    CGFloat originX = [self superViewHorizontalCenter] - offset;
    originX = [self recalculateFrameOriginIfExceedsMargins:originX];
    CGFloat originY = self.frame.origin.y;
    return CGPointMake(originX, originY);
};

- (CGFloat)recalculateFrameOriginIfExceedsMargins:(CGFloat)originX {
    CGFloat margin = 10.0f;
    if (originX > margin) {
        return margin;
    } else if (originX + self.frame.size.width < self.superview.bounds.size.width - margin) {
        return self.superview.bounds.size.width - self.bounds.size.width - margin;
    }
    return originX;
}


@end
