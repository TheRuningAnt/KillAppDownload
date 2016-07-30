//
//  LLProgressView.h
//  TestBezier_0722
//
//  Created by 赵广亮 on 16/7/22.
//  Copyright © 2016年 zhaoguangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLProgressView : UIView
/**
 *  自动加载进度
 *
 *  @param frame         将要创建的视图大小
 *  @param trackColor    轨道颜色
 *  @param progressColor 进度条颜色
 *  @param lineWidth     进度条宽度
 *  @param progressValue 进度值
 *  @param fontsize      进度提示Label字体大小
 *  @param autoLoad      是否需要自动加载进度条:如果设置为YES,则自动从0加载到设置的progressValue 
                                            如果设置为NO,则直接显示设定的progressValue值,不显示动画加载的过程(可以用在显示下载进度的回调方法里)
 *
 *  @return 进度提示器
 */
-(instancetype)initWithFrame:(CGRect)frame trackColor:(UIColor*)trackColor progressColor:(UIColor*)progressColor lineWidth:(CGFloat)lineWidth progressValue:(CGFloat)progressValue fontSize:(CGFloat)fontsize autoLoad:(BOOL)autoLoad;

//若上述参数中的autoLoad设置为NO  则可以调用该方法直接设置进度条的值
//          当autoLoad设置为Yes时,该方法不进行任何操作
-(void)setProgress:(CGFloat)progress;



@end
