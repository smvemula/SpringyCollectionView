//
//  StretchyStickySpringyCollectionViewLayout.m
//  Epic
//
//  Created by david dresner on 7/17/14.
//  Copyright (c) 2014 Epic. All rights reserved.
//
//Adapted from here: https://nrj.io/stretchy-uicollectionview-headers

#import "StretchyHeaderSpringyCollectionViewLayout.h"
//#import "Globals.h"

#define kScrollPaddingRect              100.0f
#define kScrollRefreshThreshold         50.0f
#define kScrollResistanceCoefficient    1 / 1200.0f

@implementation StretchyHeaderSpringyCollectionViewLayout{
    UIDynamicAnimator *_animator;
    NSMutableSet *_visibleIndexPaths;
    CGPoint _lastContentOffset;
    CGFloat _lastScrollDelta;
    CGPoint _lastTouchLocation;
    
}

-(void)setup{
    //if(IS_OS_7_OR_LATER){
        _animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
        _visibleIndexPaths = [NSMutableSet set];
    //}
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

- (UICollectionViewScrollDirection)scrollDirection {
    // This subclass only supports vertical scrolling.
    return UICollectionViewScrollDirectionVertical;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    CGPoint contentOffset = self.collectionView.contentOffset;
    
    // only refresh the set of UIAttachmentBehaviours if we've moved more than the scroll threshold since last load
    if (fabs(contentOffset.y - _lastContentOffset.y) < kScrollRefreshThreshold && _visibleIndexPaths.count > 0){
        return;
    }
    _lastContentOffset = contentOffset;
    
    CGFloat padding = kScrollPaddingRect;
    CGRect currentRect = CGRectMake(0, contentOffset.y - padding, self.collectionView.frame.size.width, self.collectionView.frame.size.height+ 3*padding);
    
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
        NSIndexPath *indexPath = [attribute indexPath];
        if(indexPath.section == 0){
            
        }else{
            UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:attribute attachedToAnchor:attribute.center];
            spring.length = 0.75;
            spring.frequency = 2.5;
            spring.damping = 1.0;
//            spring.length = 0.1;
//            spring.frequency = 10.0;
//            spring.damping = 0.1;
        
            // If our touchLocation is not (0,0), we need to adjust our item's center
            if (_lastScrollDelta != 0) {
                [self adjustSpring:spring centerForTouchPosition:_lastTouchLocation scrollDelta:_lastScrollDelta];
            }
            [_animator addBehavior:spring];
            [_visibleIndexPaths addObject:attribute.indexPath];
        }
        
        
    }];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    // This will schedule calls to layoutAttributesForElementsInRect: as the
    // collectionView is scrolling.
    //if(!IS_OS_7_OR_LATER){
        //return YES;
    //}
    
    UIScrollView *scrollView = self.collectionView;
    _lastScrollDelta = newBounds.origin.y - scrollView.bounds.origin.y;
    
    _lastTouchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [_animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *spring, NSUInteger idx, BOOL *stop) {
        [self adjustSpring:spring centerForTouchPosition:_lastTouchLocation scrollDelta:_lastScrollDelta];
        [_animator updateItemUsingCurrentState:[spring.items firstObject]];
    }];
    
    return YES;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    //if(IS_OS_7_OR_LATER){
        CGFloat padding = kScrollPaddingRect;
        rect.size.height += 3*padding;
        rect.origin.y -= padding;
        attributes = [attributes arrayByAddingObjectsFromArray:[_animator itemsInRect:rect]];
    //}
    
    
    UICollectionView *collectionView = [self collectionView];
    UIEdgeInsets insets = [collectionView contentInset];
    CGPoint offset = [collectionView contentOffset];
    CGFloat minY = -insets.top;
    
    
    // Check if we've pulled below past the lowest position
    if (offset.y < minY) {
        
        // Figure out how much we've pulled down
        CGFloat deltaY = fabsf(offset.y - minY);
        
        for (UICollectionViewLayoutAttributes *attrs in attributes) {
            
            // Locate the header attributes
            NSString *kind = [attrs representedElementKind];
            NSIndexPath *indexPath = [attrs indexPath];
            if (kind == UICollectionElementKindSectionHeader && indexPath.section == 0) {
                
                // Adjust the header's height and y based on how much the user
                // has pulled down.
                CGSize headerSize = [self headerReferenceSize];
                CGRect headerRect = [attrs frame];
                CGFloat newHeight = MAX(minY, headerSize.height + deltaY);
                CGFloat multiplier = (newHeight / headerSize.height);
                headerRect.size.height = headerSize.height * (log10f(multiplier)+1);
                headerRect.origin.y = headerRect.origin.y - deltaY;
                [attrs setFrame:headerRect];
                break;
            }
        }
    }else{
        // Figure out how much we've gone passed topmost minY
        CGFloat deltaY = minY - offset.y;
        
        for (UICollectionViewLayoutAttributes *attrs in attributes) {
            
            // Locate the header attributes
            NSString *kind = [attrs representedElementKind];
            NSIndexPath *indexPath = [attrs indexPath];
            if (kind == UICollectionElementKindSectionHeader && indexPath.section == 0) {
                
                // Adjust the header's height and y based on position above miny
                CGSize headerSize = [self headerReferenceSize];
                CGRect headerRect = [attrs frame];
                headerRect.size.height = MIN(headerSize.height, MAX(1,headerSize.height + deltaY));
                headerRect.origin.y = headerRect.origin.y - deltaY;
                [attrs setFrame:headerRect];
                CGFloat heightPercent = headerRect.size.height / headerSize.height;
                CGFloat alpha = log10f(heightPercent)+1;
                [attrs setAlpha:alpha];
//              DLog(@"header rect frame: %f %f %f %f", headerRect.origin.y, headerRect.origin.y, headerRect.size.width, headerRect.size.height);
                
                break;
            }
        }
    }
    
    return attributes;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    //if(!IS_OS_7_OR_LATER){
        //return [super layoutAttributesForItemAtIndexPath:indexPath];
    //}
    
    id layoutAttributes = [[_animator layoutAttributesForCellAtIndexPath:indexPath] copy];
    if (!layoutAttributes)
        layoutAttributes = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
    return layoutAttributes;
}

- (void)adjustSpring:(UIAttachmentBehavior *)spring centerForTouchPosition:(CGPoint)touchLocation scrollDelta:(CGFloat)scrollDelta {
    //if(!IS_OS_7_OR_LATER)
    //return;
    CGFloat distanceFromTouch = fabsf(touchLocation.y - spring.anchorPoint.y);
    CGFloat scrollResistance = distanceFromTouch * kScrollResistanceCoefficient;
    
    UICollectionViewLayoutAttributes *item = [spring.items firstObject];
    //    DLog(@"item: %@", item);
    CGPoint center = item.center;
    if (_lastScrollDelta < 0) {
        center.y += MAX(_lastScrollDelta, _lastScrollDelta * scrollResistance);
    } else {
        center.y += MIN(_lastScrollDelta, _lastScrollDelta * scrollResistance);
    }
    item.center = center;
}

- (void)resetLayout{
    //if(IS_OS_7_OR_LATER){
        [_animator removeAllBehaviors];
        [_visibleIndexPaths removeAllObjects];
    //}
}

@end


