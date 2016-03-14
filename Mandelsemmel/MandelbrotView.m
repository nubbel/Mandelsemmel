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
    self.maxIterations = 255;
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
    NSLog(@"drawRect: %@", NSStringFromCGRect(rect));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGContextGetCTM(context);
    CGFloat scale = transform.a;

    NSLog(@"scale: %f", scale);
    
    CGRect screenRect = CGRectMake(rect.origin.x * scale,
                                   rect.origin.y * scale,
                                   rect.size.width * scale,
                                   rect.size.height * scale);
    
    CGRect viewport = CGRectMake(-2.5, -2.0, 4.0, 4.0);
    
    CGFloat pixelWidth  = viewport.size.width  / screenRect.size.width;
    CGFloat pixelHeight = viewport.size.height / screenRect.size.height;
    
    
    NSLog(@"begin drawing");
    NSDate *start = [NSDate date];
    for (int screenY = CGRectGetMinY(screenRect); screenY < CGRectGetMaxY(screenRect); ++screenY) {
        CGFloat cY = CGRectGetMinY(viewport) + (screenY + 0.5) * pixelHeight;
        
        for (int screenX = CGRectGetMinX(screenRect); screenX < CGRectGetMaxX(screenRect); ++screenX) {
            CGFloat cX = CGRectGetMinX(viewport) + (screenX + 0.5) * pixelWidth;
            
            NSUInteger iterations = mandelbrot(cX, cY, self.maxIterations);
            
            UIColor *color = self.colors[iterations];
            [color setFill];
            
            CGRect pixel = CGRectMake(screenX / scale, screenY / scale, 1, 1);
            
            CGContextFillRect(context, pixel);
        }
    }
    NSLog(@"end drawing, took: %f sec", [[NSDate date] timeIntervalSinceDate:start]);
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
