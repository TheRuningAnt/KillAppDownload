//
//  Modifier_Singleton.h
//  KillAppDownload
//
//  Created by 赵广亮 on 16/7/30.
//  Copyright © 2016年 zhaoguangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Modifier_Singleton : NSObject

+(instancetype)modifySingleton;
//保存下载数据
-(BOOL)saveDownloadData:(NSData*)resumeData;
//读取下载数据  放回resumeData直接进行下载
-(NSData*)readNeedDownloadData;
//下载完成修改目录
-(BOOL)modifyContentWithName:(NSString*)name;

@end
