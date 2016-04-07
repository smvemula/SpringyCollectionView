//
//  THSpringyFlowLayout.m
//  CollectionViewTest
//
//  Created by Tristan Himmelman on 2013-09-22.
//  Copyright (c) 2013 Tristan Himmelman. All rights reserved.
//

#import "THSpringyFlowLayout.h"

@implementation THSpringyFlowLayout {
    UIDynamicAnimator *_animator;
    NSMutableSet *_visibleIndexPaths;    
    CGPoint _lastContentOffset;
    CGFloat _lastScrollDelta;
    CGPoint _lastTouchLocation;
}

#define kScrollPaddingRect              0.0f//100.0f
#define kScrollRefreshThreshold         0.0f//50.0f
#define kScrollResistanceCoefficient    1 / 1000.0f

-(void)setup{
    _animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    _visibleIndexPaths = [NSMutableSet set];
}

- (id)init {
    self = [super init];
    if (self){
        [self setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    CGPoint contentOffset = self.collectionView.contentOffset;

    // only refresh the set of UIAttachmentBehaviours if we've moved more than the scroll threshold since last load
    if (fabs(contentOffset.x - _lastContentOffset.x) < kScrollRefreshThreshold && _visibleIndexPaths.count > 0){
        return;
    }
    _lastContentOffset = contentOffset;

    CGFloat padding = kScrollPaddingRect;
    CGRect currentRect = CGRectMake(contentOffset.x + padding, 0, self.collectionView.frame.size.width + 3*padding, self.collectionView.frame.size.height);
    
    NSArray *itemsInCurrentRect = [super layoutAttributesForElementsInRect:currentRect];
    NSSet *indexPathsInVisibleRect = [NSSet setWithArray:[itemsInCurrentRect valueForKey:@"indexPath"]];

    // Remove behaviours that are no longer visible
    [_animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *behaviour, NSUInteger idx, BOOL *stop) {
        UICollectionViewLayoutAttributes *firstObject = (UICollectionViewLayoutAttributes*) [behaviour.items firstObject];
        if (firstObject) {
            NSIndexPath *indexPath = [firstObject indexPath];
            
            BOOL isInVisibleIndexPaths = [indexPathsInVisibleRect member:indexPath] != nil;
            if (!isInVisibleIndexPaths){
                [_animator removeBehavior:behaviour];
                [_visibleIndexPaths removeObject:indexPath];
            }
        }

    }];

    // Find newly visible indexes
    NSArray *newVisibleItems = [itemsInCurrentRect filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {

        BOOL isInVisibleIndexPaths = [_visibleIndexPaths member:item.indexPath] != nil;
        return !isInVisibleIndexPaths;
    }]];

    [newVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:attribute attachedToAnchor:attribute.center];
        spring.length = 1.0;
        spring.frequency = 3.0;
        spring.damping = 1.0;
        
        [_animator addBehavior:spring];
        [_visibleIndexPaths addObject:attribute.indexPath];
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    //if(!IS_OS_7_OR_LATER) return [super layoutAttributesForElementsInRect:rect];
    
    CGFloat padding = kScrollPaddingRect;
    rect.origin.x -= padding;
    return [_animator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    //if(!IS_OS_7_OR_LATER) return[super layoutAttributesForItemAtIndexPath:indexPath];
    
    id layoutAttributes = [_animator layoutAttributesForCellAtIndexPath:indexPath];
    if (!layoutAttributes)
        layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    return layoutAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    //f(!IS_OS_7_OR_LATER) return NO;
    
    UIScrollView *scrollView = self.collectionView;
    _lastScrollDelta = newBounds.origin.x - scrollView.bounds.origin.x;
    
    _lastTouchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [_animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *spring, NSUInteger idx, BOOL *stop) {
        [self adjustSpring:spring centerForTouchPosition:_lastTouchLocation scrollDelta:_lastScrollDelta];
        [_animator updateItemUsingCurrentState:[spring.items firstObject]];
    }];
    
    return NO;
}

- (void)adjustSpring:(UIAttachmentBehavior *)spring centerForTouchPosition:(CGPoint)touchLocation scrollDelta:(CGFloat)scrollDelta {
    CGFloat distanceFromTouch = fabs(touchLocation.x - spring.anchorPoint.x);
    CGFloat scrollResistance = distanceFromTouch * kScrollResistanceCoefficient;
    
    UICollectionViewLayoutAttributes *item = [spring.items firstObject];
    CGPoint center = item.center;
    if (_lastScrollDelta < 0) {
        center.x += MAX(_lastScrollDelta, _lastScrollDelta * scrollResistance);
    } else {
        center.x += MIN(_lastScrollDelta, _lastScrollDelta * scrollResistance);
    }
    item.center = center;
}

- (void)resetLayout{
    //if(!IS_OS_7_OR_LATER) return;
    [_animator removeAllBehaviors];
    [_visibleIndexPaths removeAllObjects];
}

@end
