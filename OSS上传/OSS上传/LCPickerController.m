//
//  LCPickerController.m
//  me
//
//  Created by edison on 2017/5/14.
//  Copyright © 2017年 edison. All rights reserved.
//

#import "LCPickerController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface LCPickerController ()<UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, copy) Success SISuccess;
@property (nonatomic, copy) Failure SIFailure;
@property (nonatomic, copy) Success SVSuccess;
@property (nonatomic, copy) Failure SVFailure;
@end

@implementation LCPickerController


- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - 2.配置打开相册或者相机的相关属性 -
// 从相册选取图片
- (void) configureForSelectImageFromPhotos
{
    if (![self isHaveAuthorityToAccessPhotos]) {
        [self alertMessage:@"没有权限访问您的相册,请在“设置”中启用访问"];
        return;
    }
    else if (![self isPhotosAvailable])
    {
        NSLog(@"相册不可用");
        return;
    }
    self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.mediaTypes = @[(__bridge NSString *)kUTTypeImage];
    self.allowsEditing = YES;
    self.delegate   = self;
}


// 调用相机拍摄图片
- (void) configureForTakeAPhoto
{
    if (![self isHaveAuthorityToAccessCamera]) {
        [self alertMessage:@"没有权限访问您的相机，请在“设置”中启用访问"];
        return;
    }
    else if (![self isCameraAvailable])
    {
        NSLog(@"相机不可用");
        return;
    }
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.mediaTypes = @[(__bridge NSString *)kUTTypeImage];
    self.delegate   = self;
}


#pragma mark ====从相册选取视频或录像
// 从相册选取视频
- (void) configureForSelectVideoFromPhotos
{
    if (![self isHaveAuthorityToAccessPhotos]) {
        [self alertMessage:@"没有权限访问您的相册，请在“设置”中启用访问"];
        return;
    }
    else if (![self isPhotosAvailable])
    {
        NSLog(@"相册不可用");
        return;
    }
    self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.mediaTypes = @[(__bridge NSString *)kUTTypeMovie];
   self.delegate   = self;
}


#pragma mark ==== 调用相机拍摄视频
- (void) configureForTakeAVideo
{
    if (![self isHaveAuthorityToAccessCamera]) {
        [self alertMessage:@"没有权限访问您的相机，请在“设置”中启用访问"];
        return;
    }
    else if (![self isCameraAvailable])
    {
        NSLog(@"相机不可用");
        return;
    }
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.mediaTypes = @[(__bridge NSString *)kUTTypeMovie];
    self.videoQuality = UIImagePickerControllerQualityTypeMedium;
    self.videoMaximumDuration = 10;
    self.delegate   = self;
}


#pragma mark - UIImagePickerControllerDelegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
            NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        
            // 图片
            if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]) {
                UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
                if (image) {
                    self.didFinishBlock ? self.didFinishBlock(image):nil;
                }
                else
                {
                    self.didFailBlock ? self.didFailBlock(nil):nil;
                }
                // 这里得保存一下新拍的照片, 然后走回调
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        
            // 视频
            else if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie]){
                
                NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
                if (url) {
                    self.didFinishBlock ? self.didFinishBlock(url):nil;
                }
                else{
                    self.didFailBlock ? self.didFailBlock(nil):nil;
                }
                NSString *videoPathString = (NSString *)([info[@"UIImagePickerControllerMediaURL"] path]);
                // 是否保存录像到相册(不写的话就是不保存), 保存后有一个回调方法
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPathString)) {
                    
                    UISaveVideoAtPathToSavedPhotosAlbum(videoPathString, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                }

            }
        
            else{
                self.didFailBlock ? self.didFailBlock(nil):nil;
            }
        
    }];
}


#pragma mark ===用户取消操作=====
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.didFailBlock ? self.didFailBlock(nil):nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark ===保存图片到相册回调====
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        self.SIFailure ? self.SIFailure(error):nil;
    }
    else
    {
        self.SISuccess ? self.SISuccess(image):nil;
    }
}


#pragma mark ====保存视频后回调====
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        self.SVFailure ? self.SVFailure(error):nil;
    }
    else
    {
        self.SVSuccess ? self.SVSuccess(videoPath):nil;
    }
}


#pragma mark - * UIAlertView 针对相册权限提示-
- (void)alertMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"先这样吧" otherButtonTitles:@"去启用", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if (buttonIndex == 0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - 1.检测属性，检查可用性 -
// 判断是否有权限访问相机
- (BOOL)isHaveAuthorityToAccessCamera
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if ((authStatus == AVAuthorizationStatusRestricted) || (authStatus == AVAuthorizationStatusDenied))
    {
        return NO;
    }
    return YES;
}


#pragma mark ====判断是否有权限访问相册
- (BOOL)isHaveAuthorityToAccessPhotos
{
    ALAuthorizationStatus status  = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

#pragma mark ==== 判断相机是否可用
- (BOOL)isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark ==== 判断前置相机是否可用
- (BOOL)isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

#pragma mark ====判断后置相机是否可用
- (BOOL)isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

#pragma mark ==== 相册是否可用
- (BOOL)isPhotosAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}



@end
