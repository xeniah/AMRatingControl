//
//  StarRatingControl.m
//  RatingControl
//


#import "StarRatingControl.h"


// Constants :
static const CGFloat kFontSize = 20;
static const NSInteger kStarWidthAndHeight = 20;
static const NSInteger kStarSpacing = 0;

static const NSString *kDefaultEmptyChar = @"☆";
static const NSString *kDefaultSolidChar = @"★";


@interface StarRatingControl (Private)

- (id)initWithLocation:(CGPoint)location
            emptyImage:(UIImage *)emptyImageOrNil
            solidImage:(UIImage *)solidImageOrNil
            emptyColor:(UIColor *)emptyColor
            solidColor:(UIColor *)solidColor
          andMaxRating:(NSInteger)maxRating;

- (void)adjustFrame;
- (void)handleTouch:(UITouch *)touch;

@end


@implementation StarRatingControl
{
    BOOL _respondsToTranslatesAutoresizingMaskIntoConstraints;
    UIImage *_emptyImage, *_solidImage, *_halfFilledImage;
    UIColor *_emptyColor, *_solidColor;
    NSInteger _maxRating;
}

/**************************************************************************************************/
#pragma mark - Getters & Setters

- (void)setMaxRating:(NSInteger)maxRating
{
    _maxRating = maxRating;
    if (_rating > maxRating) {
        _rating = maxRating;
    }
    [self adjustFrame];
    [self setNeedsDisplay];
}

- (void)setRating:(NSInteger)rating
{
    _rating = (rating < 0) ? 0 : rating;
    _rating = (rating > _maxRating) ? _maxRating : rating;
    [self setNeedsDisplay];
}

- (void)setStarWidthAndHeight:(NSUInteger)starWidthAndHeight
{
    _starWidthAndHeight = starWidthAndHeight;
    [self adjustFrame];
    [self setNeedsDisplay];
}

- (void)setStarSpacing:(NSUInteger)starSpacing
{
    _starSpacing = starSpacing;
    [self adjustFrame];
    [self setNeedsDisplay];
}

/**************************************************************************************************/
#pragma mark - Birth & Death

- (id)initWithLocation:(CGPoint)location andMaxRating:(NSInteger)maxRating
{
    return [self initWithLocation:location
                       emptyImage:nil
                       solidImage:nil
                       emptyColor:nil
                       solidColor:nil
                     andMaxRating:maxRating];
}

- (id)initWithLocation:(CGPoint)location
            emptyImage:(UIImage *)emptyImageOrNil
            solidImage:(UIImage *)solidImageOrNil
          andMaxRating:(NSInteger)maxRating
{
	return [self initWithLocation:location
                       emptyImage:emptyImageOrNil
                       solidImage:solidImageOrNil
                       emptyColor:nil
                       solidColor:nil
                     andMaxRating:maxRating];
}

- (id)initWithLocation:(CGPoint)location
            emptyImage:(UIImage *)emptyImageOrNil
            solidImage:(UIImage *)solidImageOrNil
userInteractionEnabled:(BOOL)userInteractionEnabled
         initialRating:(float)initialRating
          andMaxRating:(NSInteger)maxRating
{
    return [self initWithLocation:location
                       emptyImage:emptyImageOrNil
                       solidImage:solidImageOrNil
                        halfImage:nil
           userInteractionEnabled:userInteractionEnabled
                    initialRating:initialRating
                     andMaxRating:maxRating];
}


- (id)initWithLocation:(CGPoint)location
            emptyImage:(UIImage *)emptyImageOrNil
            solidImage:(UIImage *)solidImageOrNil
             halfImage:(UIImage *)halfFillerImageOrNil
userInteractionEnabled:(BOOL)userInteractionEnabled
         initialRating:(float)initialRating
          andMaxRating:(NSInteger)maxRating
{
	return [self initWithLocation:location
                       emptyImage:emptyImageOrNil
                       solidImage:solidImageOrNil
                        halfImage:halfFillerImageOrNil
                       emptyColor:nil
                       solidColor:nil
           userInteractionEnabled:userInteractionEnabled
                    initialRating:initialRating
                     andMaxRating:maxRating];
}


- (id)initWithLocation:(CGPoint)location
            emptyColor:(UIColor *)emptyColor
            solidColor:(UIColor *)solidColor
          andMaxRating:(NSInteger)maxRating
{
    return [self initWithLocation:location
                       emptyImage:nil
                       solidImage:nil
                       emptyColor:emptyColor
                       solidColor:solidColor
                     andMaxRating:maxRating];
}

- (void)dealloc
{
	_emptyImage = nil,
	_solidImage = nil;
    _emptyColor = nil;
    _solidColor = nil;
}

/**************************************************************************************************/
#pragma mark - Auto Layout

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(_maxRating * _starWidthAndHeight + (_maxRating - 1) * _starSpacing,
                      _starWidthAndHeight);
}


/**************************************************************************************************/
#pragma mark - View Lifecycle

- (void)drawRect:(CGRect)rect
{
	CGPoint currPoint = CGPointZero;
	
	for (int i = 0; i < _rating; i++)
	{
		if (_solidImage)
        {
            [_solidImage drawAtPoint:currPoint];
        }
		else
        {
            CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), _solidColor.CGColor);
            [kDefaultSolidChar drawAtPoint:currPoint withFont:[UIFont boldSystemFontOfSize:_starFontSize]];
        }
        
		currPoint.x += (_starWidthAndHeight + _starSpacing);
	}
    
	if (_partialRating > 0.0) {
        UIImage *partialStar = _halfFilledImage;
        if (!partialStar) {
            partialStar = [self partialImage:_solidImage fraction:_partialRating];
        }
        
        [partialStar drawAtPoint:currPoint];
        currPoint.x += (_starWidthAndHeight + _starSpacing);
    }
    
	NSInteger remaining = (floor)(_maxRating - _rating - _partialRating) ;
	
	for (int i = 0; i < remaining; i++)
	{
		if (_emptyImage)
        {
			[_emptyImage drawAtPoint:currPoint];
        }
		else
        {
            CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), _emptyColor.CGColor);
			[kDefaultEmptyChar drawAtPoint:currPoint withFont:[UIFont boldSystemFontOfSize:_starFontSize]];
        }
		currPoint.x += (_starWidthAndHeight + _starSpacing);
	}
}


/**************************************************************************************************/
#pragma mark - UIControl

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self handleTouch:touch];
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self handleTouch:touch];
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.editingDidEndBlock)
    {
        self.editingDidEndBlock(_rating);
    }
}


/**************************************************************************************************/
#pragma mark - Private Methods


- (void)initializeWithEmptyImage:(UIImage *)emptyImageOrNil
                      solidImage:(UIImage *)solidImageOrNil
                      emptyColor:(UIColor *)emptyColor
                      solidColor:(UIColor *)solidColor
                    andMaxRating:(NSInteger)maxRating
{
    [self initializeWithEmptyImage:emptyImageOrNil
                           solidImage:solidImageOrNil
                      halfFilledImage:nil
                           emptyColor:emptyColor
                           solidColor:solidColor
               userInteractionEnabled:YES
                     initialRating:0.0
                         andMaxRating:maxRating];
}

- (void)initializeWithEmptyImage:(UIImage *)emptyImageOrNil
                      solidImage:(UIImage *)solidImageOrNil
                 halfFilledImage:(UIImage *)halfFilledImageOrNil
                      emptyColor:(UIColor *)emptyColor
                      solidColor:(UIColor *)solidColor
          userInteractionEnabled:(BOOL)userInteractionEnabled
                   initialRating:(float)initialRating
                    andMaxRating:(NSInteger)maxRating
{
    _respondsToTranslatesAutoresizingMaskIntoConstraints = [self respondsToSelector:@selector(translatesAutoresizingMaskIntoConstraints)];
    
    _rating = 0;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    _emptyImage = emptyImageOrNil;
    _solidImage = solidImageOrNil;
    _halfFilledImage = halfFilledImageOrNil;
    _emptyColor = emptyColor;
    _solidColor = solidColor;
    _maxRating = maxRating;
    _rating =  (int)(floor(initialRating));
    _partialRating = initialRating - (float)_rating;
    _starFontSize = kFontSize;
    _starWidthAndHeight = kStarWidthAndHeight;
    _starSpacing = kStarSpacing;
    self.userInteractionEnabled = userInteractionEnabled;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self initializeWithEmptyImage:nil
                            solidImage:nil
                       halfFilledImage:nil
                            emptyColor:nil
                            solidColor:nil
                            userInteractionEnabled:YES
                            initialRating:0.0
                          andMaxRating:0];
    }
    return self;
}


- (id)initWithLocation:(CGPoint)location
            emptyImage:(UIImage *)emptyImageOrNil
            solidImage:(UIImage *)solidImageOrNil
            halfImage:(UIImage *)halfFillerImageOrNil
            emptyColor:(UIColor *)emptyColor
            solidColor:(UIColor *)solidColor
userInteractionEnabled:(BOOL)userInteractionEnabled
         initialRating:(float)initialRating
          andMaxRating:(NSInteger)maxRating
{
    if (self = [self initWithFrame:CGRectMake(location.x,
                                              location.y,
                                              (maxRating * kStarWidthAndHeight),
                                              kStarWidthAndHeight)])
	{
		[self initializeWithEmptyImage:emptyImageOrNil
                            solidImage:solidImageOrNil
                        halfFilledImage:halfFillerImageOrNil
                            emptyColor:emptyColor
                            solidColor:solidColor
                userInteractionEnabled:(BOOL)userInteractionEnabled
                         initialRating:(float)initialRating
                          andMaxRating:maxRating];
	}
	
	return self;
}

- (id)initWithLocation:(CGPoint)location
            emptyImage:(UIImage *)emptyImageOrNil
            solidImage:(UIImage *)solidImageOrNil
            emptyColor:(UIColor *)emptyColor
            solidColor:(UIColor *)solidColor
          andMaxRating:(NSInteger)maxRating
{
    if (self = [self initWithFrame:CGRectMake(location.x,
                                              location.y,
                                              (maxRating * kStarWidthAndHeight),
                                              kStarWidthAndHeight)])
	{
		[self initializeWithEmptyImage:emptyImageOrNil
                            solidImage:solidImageOrNil
                                halfFilledImage:nil
                            emptyColor:emptyColor
                            solidColor:solidColor
                userInteractionEnabled:YES
                         initialRating:0.0f
                          andMaxRating:maxRating];
	}
	
	return self;
}


- (void)adjustFrame
{
    if (_respondsToTranslatesAutoresizingMaskIntoConstraints && !self.translatesAutoresizingMaskIntoConstraints)
    {
        [self invalidateIntrinsicContentSize];
    }
    else
    {
        CGRect newFrame = CGRectMake(self.frame.origin.x,
                                     self.frame.origin.y,
                                     _maxRating * _starWidthAndHeight + (_maxRating - 1) * _starSpacing,
                                     _starWidthAndHeight);
        self.frame = newFrame;
    }
}

- (void)handleTouch:(UITouch *)touch
{
    if (!self.userInteractionEnabled) {
        return;
    }
    CGFloat width = self.frame.size.width;
	CGRect section = CGRectMake(0, 0, _starWidthAndHeight, self.frame.size.height);
	
	CGPoint touchLocation = [touch locationInView:self];
	
	if (touchLocation.x < 0)
	{
		if (_rating != 0)
		{
			_rating = 0;
            if (self.editingChangedBlock)
            {
                self.editingChangedBlock(_rating);
            }
		}
	}
	else if (touchLocation.x > width)
	{
		if (_rating != _maxRating)
		{
			_rating = _maxRating;
            if (self.editingChangedBlock)
            {
                self.editingChangedBlock(_rating);
            }
		}
	}
	else
	{
		for (int i = 0 ; i < _maxRating ; i++)
		{
			if ((touchLocation.x > section.origin.x) && (touchLocation.x < (section.origin.x + _starWidthAndHeight)))
			{
				if (_rating != (i + 1))
				{
					_rating = i + 1;
                    if (self.editingChangedBlock)
                    {
                        self.editingChangedBlock(_rating);
                    }
				}
				break;
			}
			section.origin.x += (_starWidthAndHeight + _starSpacing);
		}
	}
	[self setNeedsDisplay];
}

- (UIImage *) partialImage:(UIImage *)image fraction:(float)fraction
{
    CGImageRef imgRef = image.CGImage;
    CGImageRef fractionalImgRef = CGImageCreateWithImageInRect(imgRef, CGRectMake(0, 0, image.size.width * fraction, image.size.height));
    UIImage *fractionalImg = [UIImage imageWithCGImage:fractionalImgRef];
    CGImageRelease(fractionalImgRef);
    return fractionalImg;
}

@end
