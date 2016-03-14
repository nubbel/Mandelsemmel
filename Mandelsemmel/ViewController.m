//
//  ViewController.m
//  Mandelsemmel
//
//  Created by Dominique d'Argent on 12/03/16.
//  Copyright © 2016 Dominique d'Argent. All rights reserved.
//

#import "ViewController.h"
#import "MandelbrotView.h"

@interface ViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet MandelbrotView *mandelbrotView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 1000000;
    
    self.mandelbrotView.tiledLayer.levelsOfDetail = 1000;
    self.mandelbrotView.tiledLayer.levelsOfDetailBias = 500;
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mandelbrotView;
}

@end
