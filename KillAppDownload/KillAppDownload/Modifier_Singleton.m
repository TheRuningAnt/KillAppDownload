//
//  Modifier_Singleton.m
//  KillAppDownload
//
//  Created by 赵广亮 on 16/7/30.
//  Copyright © 2016年 zhaoguangliang. All rights reserved.
//

#import "Modifier_Singleton.h"
#import "GDataXMLNode.h"

@implementation Modifier_Singleton

static Modifier_Singleton *modify_Singleton = nil;

+(instancetype)modifySingleton{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!modify_Singleton) {
            modify_Singleton = [[Modifier_Singleton alloc] init];
        }
            });
    return modify_Singleton;
}

-(instancetype)init{
    @synchronized (self) {
        if(!modify_Singleton){
            self = [super init];
        }
        return self;
    }
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    @synchronized (self) {
        if (!modify_Singleton) {
            modify_Singleton = [super allocWithZone:zone];
        }
        return modify_Singleton;
    }
}

-(BOOL)saveDownloadData:(NSData*)resumeData{
    @synchronized (self) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *name = [self getNameFromData:resumeData];
        
        //获取临时文件的路径
        NSString *tmpPath = NSTemporaryDirectory();
        NSString *tmpStr = [NSString stringWithFormat:@"%@%@",tmpPath,name];
        NSURL *tmpUrl = [NSURL fileURLWithPath:tmpStr];
        
        //获取存储临时文件的路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSURL *saveTmpUrl = [NSURL fileURLWithPath:paths[0]];
        saveTmpUrl = [saveTmpUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",name]];
        
        //获取存放resumeData的路径
        NSURL *saveResumeDatUrl = [NSURL fileURLWithPath:paths[0]];
        saveResumeDatUrl = [saveResumeDatUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"Resume_%@",name]];
        
        //获取管理缓存的plist字典  不存在的话 就创建一个
        NSURL *moviePlistUrl = [NSURL fileURLWithPath:paths[0]];
        moviePlistUrl = [moviePlistUrl URLByAppendingPathComponent:@"movie.plist"];
        NSMutableDictionary *dicOfMovie;
        if([manager fileExistsAtPath:moviePlistUrl.path]) {
            dicOfMovie = [NSMutableDictionary dictionaryWithContentsOfURL:moviePlistUrl];
        }else{
            dicOfMovie = [NSMutableDictionary dictionary];
            [dicOfMovie writeToFile:moviePlistUrl.path atomically:YES];
        }
        
        NSError *error = nil;
        //拷贝tmp文件至Caches文件夹
        if ([manager fileExistsAtPath:saveTmpUrl.path]) {
            [manager removeItemAtURL:saveTmpUrl error:nil];
        }
        if(![manager copyItemAtURL:tmpUrl toURL:saveTmpUrl error:&error]){
            NSLog(@"拷贝临时文件失败  %@",error);
            return NO;
        }
        //将resumeData写入到Document文件夹下
        if ([manager fileExistsAtPath:saveResumeDatUrl.path]) {
            [manager removeItemAtURL:saveResumeDatUrl error:nil];
        }
        if(![resumeData writeToURL:saveResumeDatUrl atomically:YES]){
            NSLog(@"写入resumeData失败");
            return NO;
        }
        
        //修改缓存目录
        if (dicOfMovie) {
            [dicOfMovie setValue:@"NO" forKey:name];
            [manager removeItemAtPath:moviePlistUrl.path error:nil];
            [dicOfMovie writeToFile:moviePlistUrl.path atomically:YES];
        }
        return YES;
    }
}

-(NSData*)readNeedDownloadData{
    @synchronized (self) {
        //读取缓存目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSURL *moviePlistUrl = [NSURL fileURLWithPath:paths[0]];
        moviePlistUrl = [moviePlistUrl URLByAppendingPathComponent:@"movie.plist"];

        //获取需要重新下载的文件名
        NSDictionary *listDic = [NSDictionary dictionaryWithContentsOfURL:moviePlistUrl];
        __block NSString *cacheName = nil;
        [listDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:@"NO"]) {
                cacheName = key;
                *stop = YES;
            }
        }];
        
        
        //返回需要下载的数据
        NSData *data = nil;
        if (cacheName) {
            //caches文件下目录
            NSURL *cacheTmpUrl = [NSURL fileURLWithPath:paths[0]];
            cacheTmpUrl = [cacheTmpUrl URLByAppendingPathComponent:cacheName];
            
            //tmp文件目录
            NSString *tmpContent = NSTemporaryDirectory();
            NSString *tmpStr = [NSString stringWithFormat:@"%@%@",tmpContent,cacheName];
            NSURL *tmpSaveUrl = [NSURL fileURLWithPath:tmpStr];
            
            //将缓存文件拷贝至tmp目录下
            NSFileManager *manager = [NSFileManager defaultManager];
            NSError *error;
            if ([manager fileExistsAtPath:tmpSaveUrl.path]) {
                [manager removeItemAtURL:tmpSaveUrl error:nil];
            }
            if([manager copyItemAtURL:cacheTmpUrl toURL:tmpSaveUrl error:&error]){
                //获取resumeData文件
                NSURL *resumeDatUrl = [NSURL fileURLWithPath:paths[0]];
                resumeDatUrl = [resumeDatUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"Resume_%@",cacheName]];
                data = [NSData dataWithContentsOfURL:resumeDatUrl];
            }else{
                NSLog(@"拷贝文件失败  %s error = %@",__FUNCTION__,error);
            }
        }
        return data;
    }
}

-(BOOL)modifyContentWithName:(NSString*)name{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSURL *moviePlistUrl = [NSURL fileURLWithPath:paths[0]];
    moviePlistUrl = [moviePlistUrl URLByAppendingPathComponent:@"movie.plist"];
    NSMutableDictionary *dicOfMovie;
    if([manager fileExistsAtPath:moviePlistUrl.path]) {
        dicOfMovie = [NSMutableDictionary dictionaryWithContentsOfURL:moviePlistUrl];
        [dicOfMovie setValue:@"YES" forKey:name];
    }
    
    if (dicOfMovie) {
        [manager removeItemAtURL:moviePlistUrl error:nil];
        [dicOfMovie writeToFile:moviePlistUrl.path atomically:YES];
        return YES;
    }
    
    return NO;
}



-(NSString*)getNameFromData:(NSData*)data{
    NSError *error;
    GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc] initWithData:data options:0 error:&error];
    GDataXMLElement * rootElement = [xmlDocument rootElement];
    for(GDataXMLElement * subElemet in rootElement.children){
        for (GDataXMLElement *contactElement in subElemet.children) {
            if([contactElement.stringValue rangeOfString:@"CFNetworkDownload"].location != NSNotFound){
                return contactElement.stringValue;
            }
        }
    }
    return nil;
}
@end
