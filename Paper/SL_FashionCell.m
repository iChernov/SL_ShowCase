//
//  SL_FashionCell.m
//  Showcase
//
//  Created by Exile on 29.04.14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "SL_FashionCell.h"
#import "HACollectionViewLargeLayout.h"
#import "HACollectionViewSmallLayout.h"

@implementation SL_FashionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Cell"]];
        self.backgroundView = backgroundView;
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 126, 126)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 140, 130, 110)];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.userInteractionEnabled = NO;
        _textView.font = [UIFont systemFontOfSize:13.0];
        [self.contentView addSubview:_textView];
    }
    return self;
}



- (void)willTransitionFromLayout:(UICollectionViewLayout *)oldLayout toLayout:(UICollectionViewLayout *)newLayout {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.2];
    [UIView setAnimationBeginsFromCurrentState:true];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    if ([newLayout isKindOfClass:[HACollectionViewLargeLayout class]]) {
        self.textView.frame = CGRectMake(5, 131, 315, 410);
        self.textView.userInteractionEnabled = YES;
        self.textView.editable = NO;
    } else if ([newLayout isKindOfClass:[HACollectionViewSmallLayout class]]){
        self.textView.frame = CGRectMake(5, 140, 130, 110);
        self.textView.userInteractionEnabled = NO;
        [self.textView setContentOffset:CGPointZero animated:NO];
    }
    [UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
