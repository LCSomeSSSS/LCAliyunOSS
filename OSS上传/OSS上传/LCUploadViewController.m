//
//  LCUploadViewController.h
//  me
//
//  Created by edison on 2017/5/14.
//  Copyright © 2017年 edison. All rights reserved.
//

#define WIDTH_SIZE                  [UIScreen mainScreen].bounds.size.width / 750
#define HEIGHT_SIZE                 [UIScreen mainScreen].bounds.size.height / 1334
#define ScreenWidh  [UIScreen mainScreen].bounds.size.width
#define CompressionVideoPaht [NSHomeDirectory() stringByAppendingFormat:@"/Documents/CompressionVideoField"]
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "LCPickerController.h"
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "LCUploadViewController.h"
#import "IQAudioRecorderViewController.h"
#import <SVProgressHUD.h>

#import<CommonCrypto/CommonDigest.h>
#import "LPDQuoteImagesView.h"
#import "LCAliyunOSS.h"
#import <Masonry.h>

NSString * const endpoint = @"https://oss-cn-shenzhen.aliyuncs.com";
#pragma mark - 1. 导入头文件, 遵循两个协议idna
#import <AVFoundation/AVFoundation.h>
#import <AliyunOSSiOS/OSSService.h>

#define labelMargin 20*WIDTH_SIZE
#define imageMargin 30*WIDTH_SIZE
#define margin  10*WIDTH_SIZE
#define imageWidth (ScreenWidh - 2*imageMargin -4*margin)/5
#define imageHeight imageWidth
#define height1 60*HEIGHT_SIZE
#define height2 80*HEIGHT_SIZE

@interface LCUploadViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,IQAudioRecorderViewControllerDelegate,LPDQuoteImagesViewDelegate,UIAlertViewDelegate,UINavigationBarDelegate>

@property(nonatomic,strong)LCAliyunOSS *oss;
//上传头像label
@property(nonatomic,strong)UILabel *iconLabel;
//上传头像button
@property(nonatomic,strong)UIButton *iconBtn;
//上传照片label
@property(nonatomic,strong)UILabel *imageLabel;
//上传照片背景view
@property(nonatomic,strong)LPDQuoteImagesView *photoView;
//上传音视频label
@property(nonatomic,strong)UILabel *mediaLabel;
//上传音频btn
@property(nonatomic,strong)UIButton *volumeBtn;
//上传视频btn
@property(nonatomic,strong)UIButton *videoBtn;
//上传按钮
@property(nonatomic,strong)UIButton *uploadBtn;
//头像 视频选择器
@property (nonatomic, strong) LCPickerController *LCPicker;
//头像数据
@property(nonatomic,strong)NSData *iconData;
//相册数据
@property(nonatomic,strong)NSMutableArray <NSData *>*imageDataArray;
//视频数据
@property(nonatomic,strong)NSData *videoData;
//音频数据
@property(nonatomic,strong)NSData *volumeData;
//判断头像
@property(nonatomic,assign)BOOL isIcon;
////判断相册
//@property(nonatomic,assign)BOOL isAlbum;
//判断音频
@property(nonatomic,assign)BOOL isVolume;
//判断视频
@property(nonatomic,assign)BOOL isVideo;
@property(nonatomic,assign)int age;


@end

@implementation LCUploadViewController

#pragma mark ===头像===
-(NSData *)iconData{
    if(!_iconData){
        
        _iconData = [NSData data];
    }
    return _iconData;
}


#pragma mark ===保存相册数组===
-(NSMutableArray *)imageDataArray{
    if(!_imageDataArray){
        
        _imageDataArray = [[NSMutableArray alloc]init];
        
        //获取多选图片
        NSArray <UIImage *> *imageArray = [NSArray arrayWithArray: self.photoView.selectedPhotos];
        
        NSMutableArray<NSData *>*imageDataArray = [[NSMutableArray alloc] init];
    
        
        for(UIImage *imageObject in imageArray){
            
            NSData *imageData = UIImageJPEGRepresentation(imageObject, 0.3);
            
            //UIImage转换为NSData
            
            [imageDataArray addObject:imageData];
            
        }
            self.imageDataArray = imageDataArray;
        
        }
    return _imageDataArray;
}

#pragma mark ===视频数据===
-(NSData *)videoData{
    if(!_videoData){
        
        _videoData = [NSData data];
    }
    return _videoData;
}


#pragma mark ===音频数据===
-(NSData *)volumeData{
    if(!_volumeData){
        
        _volumeData = [NSData data];
    }
    
    return _volumeData;
}


#pragma mark ===viewDidLoad====
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
   
    // 初始化各种设置
    [[LCAliyunOSS sharedInstance] setupEnvironment];
    
    self.LCPicker = [[LCPickerController alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setMain];
    
    //获取通知中心单例对象
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [center addObserver:self selector:@selector(wrong) name:@"123" object:nil];
    
  
 }


#pragma mark ===上传=====
- (void)clickUpload:(UIButton *)sender{

    //如果上传有一个为空 那么就无法上传
    if(self.photoView.selectedPhotos.count < 5 || self.isIcon == NO || self.isVideo == NO || self.isVolume == NO ){
        
        [SVProgressHUD showInfoWithStatus:@"请完善信息"];
        [SVProgressHUD dismissWithDelay:0.5];
        
    }else{
        
        //点击上传后一直到下载完成才消失
        [SVProgressHUD show];
        [self.view setUserInteractionEnabled:NO];
        //把所有上传的方法放在调度组里
        /** 调度组-在一组异步代码执行完毕后，统一获得通知 */
      
        // 1. 调度组
        dispatch_group_t group = dispatch_group_create();

        
        
        // 2. 并发队列
        dispatch_queue_t queue = dispatch_queue_create("cn.edison", DISPATCH_QUEUE_CONCURRENT);
        
        // 将 任务添加到 调度组中
        dispatch_group_async(group, queue, ^{
            
            //上传头像
            [self uploadType:headimage andData:nil andAlbumNumber:nil];
            
        });
        
        dispatch_group_async(group, queue, ^{
            
            //上传相册
            [self uploadType:album andData:nil andAlbumNumber:nil];
            
        });
        
        dispatch_group_async(group, queue, ^{
            
            
            //上传视频
            [self uploadType:video andData:nil andAlbumNumber:nil];
            
        });
        
        dispatch_group_async(group, queue, ^{
            //上传音频
            [self uploadType:audio andData:nil andAlbumNumber:nil];
            
        });
        
        // 是异步的,等所有任务离开组就调用 dispatch_group_notify
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            
            //任务执行完后弹框消失
            [SVProgressHUD dismiss];
            [self.view setUserInteractionEnabled:YES];
            //如果失败弹框显示失败 继续停留在本页面
            if(self.age == 10){
                
                [SVProgressHUD showErrorWithStatus:@"上传失败"];
     
                self.age = 5;
                
            }else{
                
              //如果成功弹框显示 然后点击跳转界面
                [[[UIAlertView alloc]initWithTitle:@"上传成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil]show];
                
            }
            
        });
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [SVProgressHUD dismiss];
}


#pragma mark ====错误回调===
-(void)wrong{

    self.age = 10;
    
}



#pragma mark ===根据类型判断上传====
-(void)uploadType:(mimeType)uploadType andData:(NSData *)data andAlbumNumber:(NSString *)number{

    //用日期给文件命名
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@",str];
    NSLog(@"%@",fileName);
    
    //视频名
    NSString *objectKey1 = [NSString stringWithFormat:@"video%@.mp4",fileName];
    //音频名
    NSString *objectKey2 = [NSString stringWithFormat:@"volume%@.mp3",fileName];
    //上传头像名
    NSString *objectKey3 = [NSString stringWithFormat:@"anchorImage%@.png",fileName];

    switch (uploadType) {
            
        //相册
        case album:
            for (int i = 0; i<self.imageDataArray.count;i++) {
                NSString *objectKey = [NSString stringWithFormat:@"anchorAlbum%d%@.png",i,fileName];
                NSData *albumData = self.imageDataArray[i];
                [[LCAliyunOSS sharedInstance]uploadObjectAsyncWith:albumData withObjectKey:objectKey withAlbumNumber:nil];
            }
            break;
            
        //上传视频
        case video:
           
            [[LCAliyunOSS sharedInstance]uploadObjectAsyncWith:self.videoData withObjectKey:objectKey1 withAlbumNumber:nil];
            
            break;
            
        //上传语音
        case audio:
            
            [[LCAliyunOSS sharedInstance]uploadObjectAsyncWith:self.volumeData withObjectKey:objectKey2 withAlbumNumber:nil];
            
            break;
        
        //主播注册时头像
        case headimage:
            
           [[LCAliyunOSS sharedInstance] uploadObjectAsyncWith:self.iconData withObjectKey:objectKey3 withAlbumNumber:nil];
            
            break;
           
            
            default:
            break;
    }
}


#pragma mark ==== UIAlertController选项 ====
-(void)pickerImage{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册选取图片" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        [self.LCPicker configureForSelectImageFromPhotos];
        
        self.LCPicker.didFailBlock = ^(NSError *error)
        {
            NSLog(@"没有获取到资源");
        };
        
        [self presentViewController:self.LCPicker animated:YES completion:nil];
        
    }];
    
    
    UIAlertAction *videoAction = [UIAlertAction actionWithTitle:@"拍照" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        [self.LCPicker configureForTakeAPhoto];
        
        self.LCPicker.didFailBlock = ^(NSError *error)
        {
            NSLog(@"没有获取到资源");
        };
        [self presentViewController:self.LCPicker animated:YES completion:nil];
        
    }];
    
    //图片赋值给imageBtn
    __weak typeof(self) weakSelf = self;
    self.LCPicker.didFinishBlock = ^(id data){
        UIImage *image = (UIImage *)data;
        
        [weakSelf.iconBtn setImage:image forState:UIControlStateNormal];
        NSData *iconData = UIImageJPEGRepresentation(image,1.0);
        weakSelf.iconData = iconData;
        //如果获取头像成功状态改为yes
        
        weakSelf.isIcon = YES;
    };
 
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    
    [alertController addAction:photoAction];
    [alertController addAction:videoAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


#pragma mark====从相册选取视频或录像======
-(void)pickerVideo{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册选取视频" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        [self.LCPicker configureForSelectVideoFromPhotos];
        
        self.LCPicker.didFailBlock = ^(NSError *error)
        {
            NSLog(@"没有获取到资源");
        };
        [self presentViewController:self.LCPicker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *videoAction = [UIAlertAction actionWithTitle:@"录像" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        [self.LCPicker configureForTakeAVideo];
        
        self.LCPicker.didFailBlock = ^(NSError *error)
        {
            NSLog(@"没有获取到资源");
        };
        [self presentViewController:self.LCPicker animated:YES completion:nil];
    }];
    
    
    __weak typeof(self) weakSelf = self;
    self.LCPicker.didFinishBlock = ^(id data){
        NSURL *url = (NSURL *)data;
        NSLog(@"%@",url);
        NSData *videoData = [NSData dataWithContentsOfURL:url];
        
        // 获取视频大小
        NSInteger videoMemerySize = videoData.length / (1024 * 1024);
        
        //首先判断视频大小，如果大于60兆则无法上传
        
        if(videoMemerySize >=60){
            
            NSLog(@"文件过大无法上传");
            [SVProgressHUD showInfoWithStatus:@"文件过大请重新上传"];
            
        }else{
            //如果小于60兆 压缩处理
            [weakSelf compressedVideoOtherMethodWithURL:url compressionType:AVAssetExportPresetMediumQuality compressionResultPath:^(NSString *resultPath, float memorySize) {
                
                __block NSData *videoData;
                // 压缩后的文件
                videoData = [NSData dataWithContentsOfFile:resultPath];
                
                weakSelf.videoData = videoData;
                weakSelf.isVideo = YES;
                //压缩后文件大小
                NSInteger fileSize = videoData.length / (1024 * 1024);
                
                NSLog(@"%ld",(long)fileSize);
            }];
        }
        

        
        [weakSelf.videoBtn setImage:[UIImage imageNamed:@"selectBox_ed"] forState:UIControlStateNormal];
        
    };
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    
    [alertController addAction:photoAction];
    [alertController addAction:videoAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}


#pragma mark ====视频压缩处理=====
- (void)compressedVideoOtherMethodWithURL:(NSURL *)url compressionType:(NSString *)compressionType compressionResultPath:(CompressionSuccessBlock)resultPathBlock {
    
    NSString *resultPath;
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    // 所支持的压缩格式中是否有 所选的压缩格式
    if ([compatiblePresets containsObject:compressionType]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:compressionType];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
        
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        BOOL isExists = [manager fileExistsAtPath:CompressionVideoPaht];
        
        if (!isExists) {
            
            [manager createDirectoryAtPath:CompressionVideoPaht withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        resultPath = [CompressionVideoPaht stringByAppendingPathComponent:[NSString stringWithFormat:@"outputJFVideo-%@.mov", [formater stringFromDate:[NSDate date]]]];
        
        NSLog(@"压缩文件路径 resultPath = %@",resultPath);
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         
         {
             if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                 
                 NSData *data = [NSData dataWithContentsOfFile:resultPath];
                 
                 float memorySize = (float)data.length / 1024 / 1024;
                 NSLog(@"视频压缩后大小 %f", memorySize);
                 
                 resultPathBlock (resultPath, memorySize);
                 
             } else {
                 
                 NSLog(@"压缩失败");
             }
             
         }];
        
    } else {
        
        //        NSLog(@"不支持 %@ 格式的压缩", compressionType);
    }
}




#pragma mark ====录音=====
- (void)recordLC{
    IQAudioRecorderViewController *controller = [[IQAudioRecorderViewController alloc] init];
    controller.delegate = self;
    controller.title =@"录音";
    controller.maximumRecordDuration = 100;
    controller.allowCropping = YES;

    [self presentBlurredAudioRecorderViewControllerAnimated:controller];
}


-(void)audioRecorderController:(IQAudioRecorderViewController *)controller didFinishWithAudioAtPath:(NSString *)filePath {
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSLog(@"%@",data);
    
    self.volumeData = data;
    self.isVolume = YES;
    [self.volumeBtn setImage:[UIImage imageNamed:@"selectBox_ed"] forState:UIControlStateNormal];
    //Do your custom work with file at filePath.
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)audioRecorderControllerDidCancel:(IQAudioRecorderViewController *)controller {
    //Notifying that user has clicked cancel.
    [controller dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark === 头像label===
-(UILabel *)iconLabel{
    if(!_iconLabel){
        
        _iconLabel = [[UILabel alloc]init];
    }
    return _iconLabel;
}


#pragma mark ===头像按钮===
-(UIButton *)iconBtn{
    if(!_iconBtn){
        
        _iconBtn = [[UIButton alloc]init];
    }
    return _iconBtn;
}


#pragma mark ===上传照片label====
-(UILabel *)imageLabel{
    
    if(!_imageLabel){
        
        _imageLabel = [[UILabel alloc]init];
    }
    return _imageLabel;
}


#pragma mark === 上传相册背景view====
-(LPDQuoteImagesView *)photoView{
    
    if(!_photoView){
        
        _photoView = [[LPDQuoteImagesView alloc]initWithFrame:CGRectMake(0, 0,ScreenWidh, 90) withCountPerRowInView:5 cellMargin:margin];
        _photoView.collectionView.scrollEnabled = NO;
        _photoView.navcDelegate = self;
        _photoView.maxSelectedCount = 5;
        
 
    }
    return _photoView;
}


#pragma mark === 上传音视频label====
-(UILabel *)mediaLabel{
    
    if(!_mediaLabel){
        
        _mediaLabel = [[UILabel alloc]init];
    }
    return _mediaLabel;
}


#pragma mark ===上传音频===
-(UIButton *)volumeBtn{
    if(!_volumeBtn){
        
        _volumeBtn = [[UIButton alloc]init];
    }
    
    return _volumeBtn;
}


#pragma mark ===上传视频===
-(UIButton *)videoBtn{
    if(!_videoBtn){
        
        _videoBtn = [[UIButton alloc]init];
    }
    return _videoBtn;
}


#pragma mark ====上传按钮====
-(UIButton *)uploadBtn{
    if(!_uploadBtn){
        
        _uploadBtn = [[UIButton alloc]init];
    }
    
    return _uploadBtn;
}


#pragma mark ====设置主要UI界面contents=======
-(void)setMain{
    
    //上传头像label
    self.iconLabel.text = @"上传头像";
    [self.view addSubview:self.iconLabel];
    [_iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(labelMargin);
        make.top.mas_equalTo(160*HEIGHT_SIZE);
    }];
    
    
    //上传头像按钮
    [self.view addSubview:self.iconBtn];
    [_iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(imageMargin);
        make.top.mas_equalTo(self.iconLabel.mas_bottom).mas_equalTo(height1);
        make.size.mas_equalTo(CGSizeMake(imageWidth, imageHeight));
    }];
    
    [self.iconBtn setImage:[UIImage imageNamed:@"icon14"] forState:UIControlStateNormal];
    [self.iconBtn setAdjustsImageWhenHighlighted:NO];
    [self.iconBtn addTarget:self action:@selector(pickerImage) forControlEvents:UIControlEventTouchUpInside];
    
    //上传照片label
    self.imageLabel.text = @"上传照片";
    [self.view addSubview:self.imageLabel];
    [_imageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconLabel.mas_left);
        make.top.mas_equalTo(self.iconBtn.mas_bottom).offset(height2);
    }];

    
    //上传照片view
    [self.view addSubview:self.photoView];
    [_photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageLabel.mas_bottom).offset(height1-20*HEIGHT_SIZE);
        make.left.mas_equalTo(self.view.mas_left);
       
        make.size.mas_equalTo(CGSizeMake(ScreenWidh, imageHeight));

    }];
    
    
    //上传音视频label
    self.mediaLabel.text = @"上传音视频";
    [self.view addSubview:self.mediaLabel];
    [_mediaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageLabel.mas_left);
        make.top.mas_equalTo(self.photoView.mas_bottom).offset(height2);
    }];
    
    
    //上传音频按钮
    [self.view addSubview:self.volumeBtn];
    [_volumeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.iconBtn.mas_left);
        make.top.mas_equalTo(self.mediaLabel.mas_bottom).offset(height1);
        make.size.mas_equalTo(CGSizeMake(imageWidth, imageHeight));
        
    }];

    [self.volumeBtn setImage:[UIImage imageNamed:@"icon13"] forState:UIControlStateNormal];
    [self.volumeBtn setAdjustsImageWhenHighlighted:NO];
    [self.volumeBtn addTarget:self action:@selector(recordLC) forControlEvents:UIControlEventTouchUpInside];
    
    
    //上传视频按钮
    [self.view addSubview:self.videoBtn];
    [_videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.volumeBtn.mas_right).offset(margin);
        make.top.mas_equalTo(self.volumeBtn.mas_top);
        make.size.mas_equalTo(CGSizeMake(imageWidth, imageHeight));
    }];

    [self.videoBtn setImage:[UIImage imageNamed:@"icon15"] forState:UIControlStateNormal];
    [self.videoBtn setAdjustsImageWhenHighlighted:NO];
    [self.videoBtn addTarget:self action:@selector(pickerVideo) forControlEvents:UIControlEventTouchUpInside];
    
    
    //上传按钮
    [self.view addSubview:self.uploadBtn];
    _uploadBtn.layer.cornerRadius = 40*HEIGHT_SIZE;
    _uploadBtn.layer.masksToBounds = YES;
    [_uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-100*HEIGHT_SIZE);
        make.size.mas_equalTo(CGSizeMake(ScreenWidh*2*0.8*WIDTH_SIZE, 80*HEIGHT_SIZE));
    }];
    
    [self.uploadBtn setTitle:@"立即上传" forState:UIControlStateNormal];
    self.uploadBtn.alpha = 0.6;
    self.uploadBtn.backgroundColor = [UIColor redColor];
    
    [self.uploadBtn addTarget:self action:@selector(clickUpload:) forControlEvents:UIControlEventTouchUpInside];
}


@end
