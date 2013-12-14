//
//  ABViewController.m
//  DrawDemo
//
//  Created by Andrew Barba on 11/29/13.
//  Copyright (c) 2013 Northeastern. All rights reserved.
//

#import "ABViewController.h"
#import "ABDrawView.h"

@interface ABViewController ()

@property (weak, nonatomic) IBOutlet ABDrawView *drawView1;
@property (weak, nonatomic) IBOutlet ABDrawView *drawView2;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ABViewController

- (IBAction)calc:(id)sender
{
    float sim = [self.drawView1 similarityToDrawView:self.drawView2] * 100;
    self.label.text = [NSString stringWithFormat:@"%.2f%%", sim];
}

- (IBAction)reset:(id)sender
{
    [self.drawView1 resetCanvas];
    [self.drawView2 resetCanvas];
}

@end
