//
//  ViewController.m
//  KillAppDownload
//
//  Created by 赵广亮 on 16/7/29.
//  Copyright © 2016年 zhaoguangliang. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()<NSURLSessionDownloadDelegate>

@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic,strong) LLProgressView *progressView;
@property (nonatomic,assign) BOOL downloading;
@property (nonatomic,assign) BOOL playing;
@property (nonatomic,strong) Modifier_Singleton *modify_Singleton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setUp];
}

#pragma mark 调用方法
-(void)setUp{
    self.view.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.progressView];
}

/*逻辑:
 1.首先检查是否正在播放或下载 
 2.然后检查内存中是否缓存过该视频 
 3.检查上次是否有未下载完的任务
 4.重新下载
 */
- (IBAction)run:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSURL *movieUrl = [NSURL fileURLWithPath:paths[0]];
    movieUrl = [movieUrl URLByAppendingPathComponent:@"冰河世纪.mov"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (self.downloading || self.playing) {
        [self tipViewWithMessage:@"正在下载或者播放"];
    }else if([manager fileExistsAtPath:movieUrl.path]){
        [self.progressView removeFromSuperview];
        [self tipViewWithMessage:@"播放本地视频"];
        [self.view addSubview:[[EasyAVPlayer alloc] initWithUrl:movieUrl]];
        self.playing = YES;
    }else if([self.modify_Singleton readNeedDownloadData]){
        [self tipViewWithMessage:@"继续上次未完成的下载"];
        NSData *data = [self.modify_Singleton readNeedDownloadData];
        self.downloadTask = [self.session downloadTaskWithResumeData:data];
        [self.downloadTask resume];
        data = nil;
    }else{
        [self.downloadTask resume];
        self.downloading = YES;
    }
}

-(void)tipViewWithMessage:(NSString*)message{
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertControl addAction:action];
    [self presentViewController:alertControl animated:YES completion:nil];
}

#pragma mark 懒加载
-(NSURLSession *)session{
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        }
    return  _session;
}

-(NSURLSessionDownloadTask *)downloadTask{
    if (!_downloadTask) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:k_DownloadURLStr]];
        _downloadTask = [self.session downloadTaskWithRequest:request];
    }
    return _downloadTask;
}

-(LLProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[LLProgressView alloc] initWithFrame:CGRectMake(0, 0, 200, 200) trackColor:[UIColor blackColor] progressColor:[UIColor orangeColor] lineWidth:20 progressValue:0.0 fontSize:24 autoLoad:NO];
        _progressView.center = CGPointMake(k_ScreenWidth/2, 240);
    }
    return _progressView;
}

-(Modifier_Singleton *)modify_Singleton{
    return [Modifier_Singleton modifySingleton];
}

#pragma mark 代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
   
    //将下载好的文件从临时存放的地址转移到Cache文件夹中
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSURL *saveUrl = [NSURL fileURLWithPath:paths[0]];
    saveUrl = [saveUrl URLByAppendingPathComponent:@"冰河世纪.mov"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:saveUrl.path]) {
        [manager removeItemAtPath:saveUrl.path error:nil];
    }
    
    [manager copyItemAtURL:location toURL:saveUrl error:nil];
    //修改目录
    [self.modify_Singleton modifyContentWithName:[location lastPathComponent]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView removeFromSuperview];
        [self.view addSubview:[[EasyAVPlayer alloc] initWithUrl:saveUrl]];
        self.playing = YES;
        self.downloading = NO;
    });

}

static float lastTotalWriten = 0;
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    __weak typeof (self)weakSelf = self;
    if (totalBytesWritten - lastTotalWriten > totalBytesExpectedToWrite / 10) {
        lastTotalWriten = totalBytesWritten;
        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            //保存数据
            if(![weakSelf.modify_Singleton saveDownloadData:resumeData]){
                NSLog(@"临时下载数据保存失败");
            }
            weakSelf.downloadTask = [weakSelf.session downloadTaskWithResumeData:resumeData];
            [weakSelf.downloadTask resume];
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:1.0 * totalBytesWritten / totalBytesExpectedToWrite];
    });
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
