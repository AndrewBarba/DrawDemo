//
//  ABDrawView.h
//  DrawDemo
//
//  Created by Andrew Barba on 11/29/13.
//  Copyright (c) 2013 Northeastern. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABDrawView : UIView

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong, readonly) NSMutableArray *allPoints;

@property (nonatomic) NSTimeInterval timeSpentDrawing;

- (float)similarityToDrawView:(ABDrawView *)drawView;

- (void)resetCanvas;

@end
