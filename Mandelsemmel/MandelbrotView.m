//
//  MandelbrotView.m
//  Mandelsemmel
//
//  Created by Dominique d'Argent on 13/03/16.
//  Copyright © 2016 Dominique d'Argent. All rights reserved.
//

#import "MandelbrotView.h"


@implementation MandelbrotView

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
    
    CGFloat pixelWidth = (CGRectGetMaxX(viewport) - CGRectGetMinX(viewport))  / (CGRectGetMaxX(screenRect) - CGRectGetMinX(screenRect));
    CGFloat pixelHeight = (CGRectGetMaxY(viewport) - CGRectGetMinY(viewport)) / (CGRectGetMaxY(screenRect) - CGRectGetMinY(screenRect));
    
    
    NSLog(@"begin drawing");
    NSDate *start = [NSDate date];
    for (int screenY = CGRectGetMinY(screenRect); screenY < CGRectGetMaxY(screenRect); ++screenY) {
        CGFloat cY = CGRectGetMinY(viewport) + (screenY + 0.5) * pixelHeight;
        
        for (int screenX = CGRectGetMinX(screenRect); screenX < CGRectGetMaxX(screenRect); ++screenX) {
            CGFloat cX = CGRectGetMinX(viewport) + (screenX + 0.5) * pixelWidth;
            
            UIColor *color = [self colorForPoint:CGPointMake(cX, cY)];
            [color setFill];
            
            CGRect pixel = CGRectMake(screenX / scale, screenY / scale, 1, 1);
            
            CGContextFillRect(context, pixel);
        }
    }
    NSLog(@"end drawing");
    
}

- (UIColor *)colorForPoint:(CGPoint)c {
    const NSUInteger MaxIterations = 255;
    NSUInteger iterations = [self calculateNumberOfMandelbrotIterationsForPoint:c withMaxIterations:MaxIterations];
    
    if (iterations == MaxIterations) {
        return [UIColor blackColor];
    }
    
    return [UIColor colorWithHue:(CGFloat)iterations/MaxIterations saturation:1.0 brightness:1.0 alpha:1.0];
    NSLog(@"end drawing, took: %f sec", [[NSDate date] timeIntervalSinceDate:start]);
}

- (NSUInteger)calculateNumberOfMandelbrotIterationsForPoint:(CGPoint)c withMaxIterations:(NSUInteger)maxIterations {
    NSUInteger iteration;
    
    const int EscapeRadius = 2;
    const int ER2 = EscapeRadius * EscapeRadius;
    
    CGPoint z = CGPointZero;
    CGPoint z2 = CGPointZero;
    
    for (iteration = 0; (z2.x + z2.y) < ER2 && iteration < maxIterations; ++iteration) {
        z.y = 2 * z.x * z.y + c.y;
        z.x = z2.x - z2.y + c.x;
        
        z2.x = z.x * z.x;
        z2.y = z.y * z.y;
    }
    
    return iteration;
}

@end
