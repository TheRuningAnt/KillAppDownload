//
//  LLProgressView.m
//  TestBezier_0722
//
//  Created by 赵广亮 on 16/7/22.
//  Copyright © 2016年 zhaoguangliang. All rights reserved.
//

#import "LLProgressView.h"

#define k_width (self.lineWidth/2, frame.size.width > frame.size.height ? frame.size.height:frame.size.width)

@interface LLProgressView()
//定义轨道layer和进度条layer
@property (nonatomic,strong) CAShapeLayer *trackLayer;
@property (nonatomic,strong) CAShapeLayer *progressLayer;
//轨道颜色以及进度条颜色
@property (nonatomic,strong) UIColor *trackColor;
@property (nonatomic,strong) UIColor *progressColor;
//视图尺寸以及线宽
@property (nonatomic,assign) CGRect frameOfFinal;
@property (nonatomic,assign) CGFloat lineWidth;
//进度值
@property (nonatomic,assign) CGFloat progressValue;
//定时器
@property (nonatomic,strong) NSTimer *timer;
//显示进度的lable
@property (nonatomic,strong) UILabel *labelOfProgress;
//字体大小
@property (nonatomic,assign) CGFloat fontSize;
//是否自动加载
@property (nonatomic,assign) BOOL autoLoad;
@end

@implementation LLProgressView

-(instancetype)initWithFrame:(CGRect)frame trackColor:(UIColor*)trackColor progressColor:(UIColor*)progressColor lineWidth:(CGFloat)lineWidth progressValue:(CGFloat)progressValue fontSize:(CGFloat)fontsize autoLoad:(BOOL)autoLoad{
    self = [super initWithFrame:frame];
    if (self) {
        self.frameOfFinal = CGRectMake(0,0, k_width,k_width);
        self.trackColor = trackColor;
        self.progressColor = progressColor;
        self.progressValue = progressValue;
        self.lineWidth = lineWidth;
        self.fontSize = fontsize;
        self.autoLoad = autoLoad;
        
        self.backgroundColor = [UIColor clearColor];
        //设置轨道和进度条 并添加到视图上去
        [self setUp];
    }
    return self;
}

-(void)setUp{
    //将轨道和进度条合并 并且添加到视图上去
    [self.layer addSublayer:self.trackLayer];
    [self.layer addSublayer:self.progressLayer];

    //添加label
    [self  addSubview:self.labelOfProgress];
    if(self.autoLoad){
        //开启定时器
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }else{
        self.progressLayer.strokeEnd = self.progressValue;
        self.labelOfProgress.text = [NSString stringWithFormat:@"%.1f%%",self.progressValue*100];
    }
    
    }

//设置track
-(CAShapeLayer *)trackLayer{
    if (!_trackLayer) {
        //创建track
        _trackLayer = [CAShapeLayer layer];
        _trackLayer.frame = self.frameOfFinal;
        _trackLayer.lineWidth = self.lineWidth;
        _trackLayer.strokeColor = self.trackColor.CGColor;
        _trackLayer.fillColor = nil;
        
        //轨道path
        UIBezierPath *trackPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.frameOfFinal.origin.x + self.lineWidth/2, self.frameOfFinal.origin.y + self.lineWidth/2, self.frameOfFinal.size.width - self.lineWidth, self.frameOfFinal.size.width - self.lineWidth)];
        _trackLayer.path = trackPath.CGPath;

    }
        return _trackLayer;
}

//设置progress
-(CAShapeLayer *)progressLayer{
    if (!_progressLayer) {
        //创建progress
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.frameOfFinal;
        _progressLayer.lineWidth = self.lineWidth + 3;
        _progressLayer.strokeColor = self.progressColor.CGColor;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.fillColor = nil;
        
        //设置开始和结束节点
        _progressLayer.strokeStart = 0.0;
        _progressLayer.strokeEnd = 0.0;
        
        //设置进度Progress  path
        UIBezierPath *progressPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.frameOfFinal.origin.x + self.lineWidth/2, self.frameOfFinal.origin.y + self.lineWidth/2, self.frameOfFinal.size.width - self.lineWidth, self.frameOfFinal.size.width - self.lineWidth)];
        _progressLayer.path = progressPath.CGPath;

    }
        return _progressLayer;
}

//设置labelOfProgress
-(UILabel *)labelOfProgress{
    if (!_labelOfProgress) {
        _labelOfProgress = [[UILabel alloc] initWithFrame:self.frameOfFinal];
        _labelOfProgress.textAlignment = NSTextAlignmentCenter;
        _labelOfProgress.font = [UIFont systemFontOfSize:self.fontSize];
    }
    return _labelOfProgress;
}


-(NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(changeProgress) userInfo:nil repeats:YES];
        
    }
    return _timer;
}

//定时器调用的方法
-(void)changeProgress{
    if (self.progressLayer.strokeEnd < self.progressValue) {
        self.progressLayer.strokeEnd += 0.041;
        self.labelOfProgress.text = [NSString stringWithFormat:@"%.1f%%",self.progressLayer.strokeEnd*100];
    }else{
        [self.timer invalidate];
        self.labelOfProgress.text = [NSString stringWithFormat:@"%.1f%%",self.progressValue*100];
        self.timer = nil;
    }
}

//手工设置进度值
-(void)setProgress:(CGFloat)progress{
    if (!self.autoLoad) {
        if (progress <= 1) {
            self.progressValue = progress;
        }else{
            self.progressValue = 1.0;
        }
        self.labelOfProgress.text = [NSString stringWithFormat:@"%.1f%%",self.progressValue*100];
        self.progressLayer.strokeEnd = ((int)(self.progressValue * 100)) / 100.0;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
