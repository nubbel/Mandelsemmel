//
//  MandelbrotView.m
//  Mandelsemmel
//
//  Created by Dominique d'Argent on 13/03/16.
//  Copyright © 2016 Dominique d'Argent. All rights reserved.
//

#import "MandelbrotView.h"

static inline NSUInteger mandelbrot(CGFloat cX, CGFloat cY, const NSUInteger maxIterations) {
    NSUInteger iteration;
    
    const CGFloat EscapeRadius = 2.0;
    const CGFloat ER2 = EscapeRadius * EscapeRadius;
    
    CGFloat zX, zY, zX2, zY2;
    zX = zY = 0.0;
    zX2 = zY2 = 0.0;
    
    for (iteration = 0; (zX2 + zY2) < ER2 && iteration < maxIterations; ++iteration) {
        zY = 2.0 * zX * zY + cY;
        zX = zX2 - zY2 + cX;
        
        zX2 = zX * zX;
        zY2 = zY * zY;
    }
    
    return iteration;
}

@interface MandelbrotView ()

@property (nonatomic) CGRect viewport;
@property (nonatomic) NSUInteger maxIterations;
@property (nonatomic, strong) NSArray<UIColor *> *colors;

@end

@implementation MandelbrotView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.viewport = CGRectMake(-2.5, -2, 5.0, 4.0);
    self.maxIterations = 255;
    self.opaque = YES;
    [self precomputeColors];
}

- (void)precomputeColors {
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:self.maxIterations + 1];
    
    for (int i = 0; i < self.maxIterations; ++i) {
        colors[i] = [UIColor colorWithHue:(CGFloat)i/self.maxIterations
                               saturation:1.0
                               brightness:1.0
                                    alpha:1.0];
    }
    colors[self.maxIterations] = [UIColor blackColor];
    
    self.colors = colors;
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"-- drawRect: %@", NSStringFromCGRect(rect));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGContextGetCTM(context);
    CGFloat scaleFactor = transform.a;
    CGAffineTransform scale = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    NSLog(@"scale: %f", scaleFactor);
    
    // we want to work on real pixels, not points
    CGContextScaleCTM(context, 1 / scaleFactor, 1 / scaleFactor);
    
    // canvas
    CGSize canvasSize = CGSizeApplyAffineTransform(self.bounds.size, scale);
    NSLog(@"canvas size: %@", NSStringFromCGSize(canvasSize));
    
    // the tile to be drawn
    CGRect tileRect = CGRectApplyAffineTransform(rect, scale);
    NSLog(@"tile: %@", NSStringFromCGRect(tileRect));
    
    const CGFloat pixelRatio = MAX(self.viewport.size.width  / canvasSize.width, self.viewport.size.height / canvasSize.height);
    
    NSLog(@"viewport: %@ (size in pixels: %@)", NSStringFromCGRect(self.viewport), NSStringFromCGSize(CGSizeApplyAffineTransform(self.viewport.size, CGAffineTransformMakeScale(1.0/pixelRatio, 1.0/pixelRatio))));
    
    const NSUInteger maxIterations = self.maxIterations;
    
    NSLog(@"begin drawing");
    NSDate *start = [NSDate date];
    for (int canvasY = CGRectGetMinY(tileRect); canvasY < CGRectGetMaxY(tileRect); ++canvasY) {
        CGFloat cY = CGRectGetMidY(self.viewport) + (canvasY - (canvasSize.height/2.0) + 0.5) * pixelRatio;
        
        for (int canvasX = CGRectGetMinX(tileRect); canvasX < CGRectGetMaxX(tileRect); ++canvasX) {
            CGFloat cX = CGRectGetMidX(self.viewport) + (canvasX - (canvasSize.width/2.0) + 0.5) * pixelRatio;
            
            NSUInteger iterations = mandelbrot(cX, cY, maxIterations);
            
            UIColor *color = self.colors[iterations];
            [color setFill];
            
            CGRect pixel = CGRectMake(canvasX, canvasY, 1, 1);
            
            CGContextFillRect(context, pixel);
        }
    }
    NSLog(@"end drawing, took: %f sec", [[NSDate date] timeIntervalSinceDate:start]);
    
#ifdef DEBUG
    [[UIColor whiteColor] setStroke];
    
    CGRect viewportInPixels = CGRectApplyAffineTransform(self.viewport, CGAffineTransformMakeScale(1.0/pixelRatio, 1.0/pixelRatio));
    viewportInPixels.origin.x = canvasSize.width/2 - viewportInPixels.size.width/2;
    viewportInPixels.origin.y = canvasSize.height/2 - viewportInPixels.size.height/2;
    CGContextStrokeRectWithWidth(context, viewportInPixels, scaleFactor * 5);
    
    [[UIColor whiteColor] setFill];
    
    // draw x axis
    CGContextFillRect(context, CGRectMake(0, canvasSize.height/2, canvasSize.width, scaleFactor));
    
    // draw y axis
    CGContextFillRect(context, CGRectMake(canvasSize.width/2, 0, scaleFactor, canvasSize.height));
#endif
}

- (NSUInteger)calculateNumberOfMandelbrotIterationsForPoint:(CGPoint)c {
    NSUInteger iteration;
    
    const int EscapeRadius = 2;
    const int ER2 = EscapeRadius * EscapeRadius;
    
    CGPoint z = CGPointZero;
    CGPoint z2 = CGPointZero;
    
    for (iteration = 0; (z2.x + z2.y) < ER2 && iteration < self.maxIterations; ++iteration) {
        z.y = 2 * z.x * z.y + c.y;
        z.x = z2.x - z2.y + c.x;
        
        z2.x = z.x * z.x;
        z2.y = z.y * z.y;
    }
    
    return iteration;
}

@end
