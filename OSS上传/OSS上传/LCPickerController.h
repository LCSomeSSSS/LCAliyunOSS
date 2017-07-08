//
//  LCPickerController.h
//  me
//
//  Created by edison on 2017/5/14.
//  Copyright © 2017年 edison. All rights reserved.
//

/*
 功能清单：
 
 1.从相册中选择图片
 2.从相册中选择视频
 3.拍照
 4.拍摄视频
 5.将图片存储到相册
 6.将图片存储到相册
 
 PS: 本类库不支持多选，以上操作每次只能获取一张图片或者一个视频，
 */

#import <UIKit/UIKit.h>

typedef void(^Success)(id _Nonnull data);
typedef void(^Failure)(NSError *_Nullable error);

@interface LCPickerController : UIImagePickerController
// 选取图片或者视频成功或者失败的回调
@property (nonatomic, copy) Success _Nonnull didFinishBlock;
@property (nonatomic, copy) Failure _Nullable didFailBlock;

/** 从相册中选择一张照片 */
- (void) configureForSelectImageFromPhotos;
/** 拍摄一张照片 */
- (void) configureForTakeAPhoto;
/** 从相册中选择一个视频 */
- (void) configureForSelectVideoFromPhotos;
/** 拍摄一个视频 */
- (void) configureForTakeAVideo;

@end
