//
//  EasyAVPlayer.m
//  KillAppDownload
//
//  Created by 赵广亮 on 16/7/29.
//  Copyright © 2016年 zhaoguangliang. All rights reserved.
//

#import "EasyAVPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface EasyAVPlayer()
@property (nonatomic,strong) AVPlayer *avPlayer;
@end

@implementation EasyAVPlayer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithUrl:(NSURL*)url{
    self = [super init];
    self.frame = CGRectMake(0, 0, k_ScreenWidth, 400);
    if (self) {
        [self addMVPlayerWithFileUrl:url];
    }
    return self;
}

-(void)addMVPlayerWithFileUrl:(NSURL*)fileUrl{
     AVURLAsset *asset = [AVURLAsset assetWithURL:fileUrl];
     AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
     self.avPlayer = [AVPlayer playerWithPlayerItem:item];
     self.avPlayer.volume = 1.0f;
    
     AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
     playerLayer.frame = self.frame;
     playerLayer.backgroundColor = [UIColor clearColor].CGColor;
     playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.layer addSublayer:playerLayer];
    [self.avPlayer play];
}



@end
