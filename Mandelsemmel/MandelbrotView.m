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
    
    // check if point lies inside the period-2 bulb
    if ((cX + 1) * (cX + 1) + cY * cY < 0.0625) {
        return maxIterations;
    }
    
    // check if point lies inside the cardioid
    CGFloat q = (cX - 0.25) * (cX - 0.25) + cY * cY;
    if (q * (q + (cX - 0.25)) < 0.25 * cY * cY) {
        return maxIterations;
    }
    
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
@property (nonatomic, assign) uint8_t *colors;

@end

@implementation MandelbrotView

+ (Class)layerClass {
    return [CATiledLayer class];
}

- (CATiledLayer *)tiledLayer {
    return (CATiledLayer *)self.layer;
}

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

- (void)dealloc {
    free(self.colors);
}

- (void)precomputeColors {
    uint8_t *colors = malloc((self.maxIterations + 1) * 3);
    
    for (int i = 0; i < self.maxIterations; ++i) {
        UIColor *color = [UIColor colorWithHue:(CGFloat)i/self.maxIterations
                               saturation:1.0
                               brightness:1.0
                                    alpha:1.0];
        
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        colors[3 * i + 0] = components[0] * 255.0;
        colors[3 * i + 1] = components[1] * 255.0;
        colors[3 * i + 2] = components[2] * 255.0;
    }
    colors[3 * self.maxIterations + 0] = 0;
    colors[3 * self.maxIterations + 1] = 0;
    colors[3 * self.maxIterations + 2] = 0;
    
    self.colors = colors;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGContextGetCTM(context);
    CGFloat scaleFactor = transform.a;
    CGAffineTransform scale = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    
    // we want to work on real pixels, not points
    CGContextScaleCTM(context, 1 / scaleFactor, 1 / scaleFactor);
    
    // canvas
    CGSize canvasSize = CGSizeApplyAffineTransform(self.bounds.size, scale);
    
    // the tile to be drawn
    CGRect tileRect = CGRectApplyAffineTransform(rect, scale);
    
    const CGFloat pixelRatio = MAX(self.viewport.size.width  / canvasSize.width, self.viewport.size.height / canvasSize.height);
    
    const NSUInteger maxIterations = self.maxIterations;
    
    CGRect viewport = self.viewport;
    uint8_t *colors = self.colors;
    
    CGFloat minX = CGRectGetMinX(tileRect);
    CGFloat maxX = CGRectGetMaxX(tileRect);
    CGFloat minY = CGRectGetMinY(tileRect);
    CGFloat maxY = CGRectGetMaxY(tileRect);
    
    // move to center of canvas; + 0.5, because we want to regard the center of the pixel
    CGFloat offsetX = canvasSize.width * 0.5 + 0.5;
    CGFloat offsetY = canvasSize.height * 0.5 + 0.5;
    
    CGFloat viewportOriginX = CGRectGetMidX(viewport);
    CGFloat viewportOriginY = CGRectGetMidY(viewport);
    
    CGFloat cX, cY;
    NSUInteger iterations;

    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    const size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace) + 1;
    const size_t bitsPerComponent = 8;
    const size_t bytesPerPixel = (bitsPerComponent * numberOfComponents + 7)/8;
    const size_t bytesPerRow = bytesPerPixel * tileRect.size.width;
    
    void *bitmap = malloc(bytesPerRow * tileRect.size.height);
    
    CGContextRef bitmapContext;
    bitmapContext = CGBitmapContextCreate(bitmap, tileRect.size.width, tileRect.size.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault);
    
    uint8_t *buf = (uint8_t *)bitmap;
    
    for (CGFloat canvasY = maxY - 1; canvasY >= minY; --canvasY) {
        cY = viewportOriginY + (canvasY - offsetY) * pixelRatio;
        
        for (CGFloat canvasX = minX; canvasX < maxX; ++canvasX) {
            cX = viewportOriginX + (canvasX - offsetX) * pixelRatio;
            
            iterations = mandelbrot(cX, cY, maxIterations);
            
            buf[0] = 0; // alpha
            buf[1] = colors[3 * iterations + 0]; // red
            buf[2] = colors[3 * iterations + 1]; // green
            buf[3] = colors[3 * iterations + 2]; // blue
            
            buf += 4;
        }
    }
    
    // draw bitmap in context
    CGImageRef tile = CGBitmapContextCreateImage(bitmapContext);
    CGContextDrawImage(context, tileRect, tile);
    
    // Cleanup
    free(bitmap);
    CFRelease(tile);
    CFRelease(colorSpace);
    CFRelease(bitmapContext);
    
#ifdef DEBUG
    [[UIColor whiteColor] setStroke];
    
    // draw viewport
    CGRect viewportInPixels = CGRectApplyAffineTransform(self.viewport, CGAffineTransformMakeScale(1.0/pixelRatio, 1.0/pixelRatio));
    viewportInPixels.origin.x = canvasSize.width/2 - viewportInPixels.size.width/2;
    viewportInPixels.origin.y = canvasSize.height/2 - viewportInPixels.size.height/2;
    CGContextStrokeRectWithWidth(context, viewportInPixels, scaleFactor * 5);
    
    [[UIColor blueColor] setStroke];
    
    // draw tile
    CGContextStrokeRectWithWidth(context, tileRect, 5);
    
    
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
