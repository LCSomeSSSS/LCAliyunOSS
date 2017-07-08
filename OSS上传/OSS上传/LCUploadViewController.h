//
//  LCUploadViewController.h
//  me
//
//  Created by edison on 2017/5/14.
//  Copyright © 2017年 edison. All rights reserved.
//

#import <UIKit/UIKit.h>

//上传类型
typedef enum {
    album = 0,                       //认证主播相册图片
    video = 1,                        //视频
    audio = 2,                       //语音
    headimage = 3,                //认证主播头像

}mimeType;

@interface LCUploadViewController : UIViewController

typedef void (^CompressionSuccessBlock)(NSString *resultPath,float memorySize); // 定义成功的Block 函数

-(void)compressedVideoOtherMethodWithURL:(NSURL *)url compressionType:(NSString *)compressionType compressionResultPath:(CompressionSuccessBlock)resultPathBlock;

-(void)uploadType:(mimeType)uploadType andData:(NSData *)data andAlbumNumber:(NSString *)number;



@end

