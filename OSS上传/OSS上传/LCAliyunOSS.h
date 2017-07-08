//
//  AliyunOSSDemo.h
//  OSS上传
//
//  Created by edison on 2017/6/7.
//  Copyright © 2017年 edison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface LCAliyunOSS : NSObject

+ (instancetype)sharedInstance;

- (void)setupEnvironment;

- (void)uploadObjectAsyncWith:(NSData *)uploadData withObjectKey:(NSString *)objectKey withAlbumNumber:(NSString *)number;


@end
