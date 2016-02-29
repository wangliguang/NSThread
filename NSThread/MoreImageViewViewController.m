//
//  MoreImageViewViewController.m
//  NSThread
//
//  Created by GG on 16/2/22.
//  Copyright © 2016年 GG. All rights reserved.
//

#pragma mark ------------------NSThread分析详解 http://www.jianshu.com/p/b1c2bd572e81-------------

#import "MoreImageViewViewController.h"


#define kUrl @"http://store.storeimages.cdn-apple.com/8748/as-images.apple.com/is/image/AppleInc/aos/published/images/s/38/s38ga/rdgd/s38ga-rdgd-sel-201601?wid=848&hei=848&fmt=jpeg&qlt=80&op_sharpen=0&resMode=bicub&op_usm=0.5,0.5,0,0&iccEmbed=0&layer=comp&.v=1454777389943"

@interface MoreImageViewViewController ()
{
    int imageIndex;
    
    NSMutableArray *threadArrays;
    
    UIImage *image;
}

@end

@implementation MoreImageViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
    
    lable.text = @"点击屏幕停止加载";
    lable.textColor = [UIColor blackColor];
    [lable sizeToFit];
    [self.view addSubview:lable];
    
    //创建多个UIImageView
    self.title = @"多线程加载多张图片";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    imageIndex = 100;
    
    for (int  row= 0; row<3; row++) {
        for (int list = 0; list<2; list++) {
            
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10+list*200, 10+row*200, 200, 200)];
            
            imageView.tag = imageIndex++;
            
            [self.view addSubview:imageView];
            
        }
    }
    
    threadArrays = [NSMutableArray array];
    
    //创建多个线程
    for (int index = 0; index<6; index++) {
        
        NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(downloadImage:) object:@(index)];
        
        //给线程设置优先级（0-1），优先级越高，被优先调用的几率越高。
        //        thread.threadPriority = index/10.0;
        thread.name = [NSString stringWithFormat:@"线程%d",index];
        [thread start];
        
        [threadArrays addObject:thread];
        
        
        
    }
}


//每条线程都会走这个方法，来下载相应的图片，在这里为了方便起见，我采用了同一个url图片
- (void)downloadImage:(NSNumber *)index{
    
    [NSThread sleepForTimeInterval:[index integerValue]];
    
    NSThread *currentThread = [NSThread currentThread];
    //如果当前线程处于取消状态，则退出当前线程
    if (currentThread.isCancelled) {
        NSLog(@"thread(%@) will be cancelled!",currentThread);
        [NSThread exit];//退出当前线程
    }
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:kUrl]];
    
    image = [UIImage imageWithData:data];
    
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:index waitUntilDone:YES];
    
    NSThread *thread = [NSThread currentThread];
    NSLog(@"当前线程是 = %@",thread.name);
    
}


- (void)updateUI:(NSNumber *)ktest{
    
    
    UIImageView *imageView = [self.view viewWithTag:100+[ktest integerValue]];
    
    imageView.image = image;
    
    
}

//点击屏幕将没有完成的线程设置为取消状态
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    for (int i=0; i<6; i++) {
        NSThread *thread= threadArrays[i];
        //判断线程是否完成，如果没有完成则设置为取消状态
        //注意设置为取消状态仅仅是改变了线程状态而言，并不能终止线程
        if (!thread.isFinished) {
            [thread cancel];
            
            NSLog(@"============");
            
        }
    }
    
}




@end
