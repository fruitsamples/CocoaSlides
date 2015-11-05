/*

File: NSImage+Conversion.m

Abstract: Category Methods for Creating an NSImage from a CGImageRef

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Computer, Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Computer,
Inc. may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright © 2006 Apple Computer, Inc., All Rights Reserved

*/

#import "NSImage+Conversion.h"

@implementation NSImage(CreatingFromCGImages)

- initWithCGImage:(CGImageRef)cgImage {
    return [self initWithCGImage:cgImage asBitmapImageRep:YES];
}

// Initializes an NSImage with a copy of the contents of the given CGImage.  If "asBitmapImageRep" is YES, the resultant NSImage will have an NSBitmapImageRep representation.  If "asBitmapImageRep" is NO, the NSImage's contents will be initialized by locking focus and drawing into it, which produces an NSCachedImageRep representation.
- initWithCGImage:(CGImageRef)cgImage asBitmapImageRep:(BOOL)asBitmapImageRep {
    if (cgImage) {
        size_t width = CGImageGetWidth(cgImage);
        size_t height = CGImageGetHeight(cgImage);
        self = [self initWithSize:NSMakeSize(width, height)];
        if (asBitmapImageRep) {
            BOOL hasAlpha = CGImageGetAlphaInfo(cgImage) == kCGImageAlphaNone ? NO : YES;
            size_t bps = 8; // hardwiring to 8 bits per sample is fine for this app's purposes
            size_t spp = hasAlpha ? 4 : 3;
            NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:width pixelsHigh:height bitsPerSample:bps samplesPerPixel:spp hasAlpha:hasAlpha isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bitmapFormat:0 bytesPerRow:0 bitsPerPixel:0];

            NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapImageRep];
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:bitmapContext];
            CGContextDrawImage((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort], CGRectMake(0.0, 0.0, width, height), cgImage);
            [NSGraphicsContext restoreGraphicsState];

            [self addRepresentation:bitmapImageRep];
            [bitmapImageRep release];
        } else {
            [self lockFocus];
            CGContextDrawImage((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort], CGRectMake(0.0, 0.0, width, height), cgImage);
            [self unlockFocus];
        }
    } else {
        self = [self init];
    }
    return self;
}

@end
