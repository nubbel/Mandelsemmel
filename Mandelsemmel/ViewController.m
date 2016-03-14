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
    
    CGFloat viewSize = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
    CGFloat scaleFactor = self.view.contentScaleFactor;
    
    // Calculate maximum levels: viewSize * scaleFactor * 2^(maxLevels) = CGFLOAT_MAX
    size_t maxLevels = (size_t)floor(log2(CGFLOAT_MAX / viewSize / scaleFactor));
    
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = maxLevels * 1000; // empircally determined
    
    self.mandelbrotView.tiledLayer.levelsOfDetail = maxLevels;
    self.mandelbrotView.tiledLayer.levelsOfDetailBias = maxLevels - 1;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mandelbrotView;
}

@end
