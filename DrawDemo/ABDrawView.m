//
//  ABDrawView.m
//  DrawDemo
//
//  Created by Andrew Barba on 11/29/13.
//  Copyright (c) 2013 Northeastern. All rights reserved.
//

#import "ABDrawView.h"

#define DRAW_VIEW_DISTANCE_THRESHOLD 100.0f

@interface ABDrawView() {
    // Timers
    NSDate *_startDate;
    
    // Drawing Vars
    UIBezierPath *_path;
    UIImage *_incrementalImage;
    CGPoint _pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint _ctr;
}

@end

@implementation ABDrawView

- (float)similarityToDrawView:(ABDrawView *)drawView
{
    NSUInteger num = MIN(_allPoints.count, drawView.allPoints.count);
    NSArray *pts1 = [self _items:num from:_allPoints];
    NSArray *pts2 = [self _items:num from:drawView.allPoints];
    return [self _similarityBetween:pts1 to:pts2];
}

- (NSArray *)_items:(NSUInteger)numOfItems from:(NSArray *)array
{
    NSMutableArray *items = [NSMutableArray array];
    float interval = ((float)array.count) / ((float)numOfItems);
    for (float x = 0.0f; x < array.count; x+=interval) {
        [items addObject:array[(int)x]];
    }
    return items;
}

- (float)_similarityBetween:(NSArray *)points1 to:(NSArray *)points2
{
    __block float ans = 0.0;
    __block NSUInteger count = 0;
    
    CGPoint a1 = [self _averagePoint:points1];
    CGPoint a2 = [self _averagePoint:points2];
    float xOff = a2.x - a1.x;
    float yOff = a2.y - a1.y;
    
    [points1 enumerateObjectsUsingBlock:^(NSValue *val, NSUInteger index, BOOL *stop){
        if (index < points2.count) {
            CGPoint p1 = [val CGPointValue];
            CGPoint p2 = [points2[index] CGPointValue];
            
            float xDist = (p2.x - xOff) - p1.x;
            float yDist = (p2.y - yOff) - p1.y;
            float dist = sqrt((xDist * xDist) + (yDist * yDist));
            
            dist = MIN(dist, DRAW_VIEW_DISTANCE_THRESHOLD);
            float perc = (DRAW_VIEW_DISTANCE_THRESHOLD - dist) / DRAW_VIEW_DISTANCE_THRESHOLD;
            ans += perc;
            count++;
        }
    }];
    
    return (count > 0) ? (ans / count) : 0.0;
}

- (CGPoint)_averagePoint:(NSArray *)points
{
    float x = 0.0;
    float y = 0.0;
    for (NSValue *val in points) {
        CGPoint p = [val CGPointValue];
        x += p.x;
        y += p.y;
    }
    return CGPointMake(x/points.count, y/points.count);
}

#pragma mark - Reset

- (void)resetCanvas
{
    _path = [UIBezierPath bezierPath];
    _path.lineWidth = 2.0f;
    _incrementalImage = nil;
    _ctr = 0;
    _timeSpentDrawing = 0.0;
    _allPoints = [NSMutableArray array];
    [self setNeedsDisplay];
}

#pragma mark - Draw Rect

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [_incrementalImage drawInRect:rect];
    [_path stroke];
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _startDate = [NSDate date];
    _ctr = 0;
    UITouch *touch = [touches anyObject];
    _pts[0] = [touch locationInView:self];
    CGPoint p = [touch locationInView:self];
    [_allPoints addObject:[NSValue valueWithCGPoint:p]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    _ctr++;
    _pts[_ctr] = p;
    if (_ctr == 4) {
        _pts[3] = CGPointMake((_pts[2].x + _pts[4].x)/2.0, (_pts[2].y + _pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        [_path moveToPoint:_pts[0]];
        [_path addCurveToPoint:_pts[3] controlPoint1:_pts[1] controlPoint2:_pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        _pts[0] = _pts[3];
        _pts[1] = _pts[4];
        _ctr = 1;
    }
    [_allPoints addObject:[NSValue valueWithCGPoint:p]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    [_allPoints addObject:[NSValue valueWithCGPoint:p]];
    [self drawBitmap];
    [self setNeedsDisplay];
    [_path removeAllPoints];
    _ctr = 0;
    _timeSpentDrawing += fabs([_startDate timeIntervalSinceNow]);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - Helper

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    if (!_incrementalImage) {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [self.backgroundColor setFill];
        [rectpath fill];
    }
    [_incrementalImage drawAtPoint:CGPointZero];
    [self.tintColor setStroke];
    [_path stroke];
    _incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

#pragma mark - Initialization

- (void)_drawCommonInit
{
    [self setMultipleTouchEnabled:NO];
    _path = [UIBezierPath bezierPath];
    [_path setLineWidth:2.0];
    _allPoints = [NSMutableArray array];
    self.tintColor = [UIColor blackColor];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _drawCommonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _drawCommonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self _drawCommonInit];
    }
    return self;
}

@end
