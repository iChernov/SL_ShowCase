//
//  SL_FashionCell.m
//  Showcase
//
//  Created by Exile on 29.04.14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "SL_FashionCell.h"


@implementation SL_FashionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Cell"]];
        self.backgroundView = backgroundView;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 70, 70)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
    }
    return self;
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
