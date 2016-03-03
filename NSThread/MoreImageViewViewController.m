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
        //thread.threadPriority = index/10.0;
        thread.name = [NSString stringWithFormat:@"线程%d",index];
        [thread start];
        
        [threadArrays addObject:thread];
        
        
        
    }
}


//每条线程都会走这个方法，来下载相应的图片，在这里为了方便起见，我采用了同一个url图片
- (void)downloadImage:(NSNumber *)index{
    
    /*
     
     * 通过线程的休眠来实现图片的顺序加载
     
        1. 第一个线程，休眠0秒，第二个线程休眠1秒...第六个线程休眠5面
     
        2. 正常的流程如下（基于线程同时执行的原理）
          
           1. 多线程开启，并在线程中写上线程休眠代码
           2. 线程执行到休眠代码，停止执行
           3. 点击屏幕，将为完成的线程设为取消状态
           4. 休眠结束，线程进行判断是否被取消，被取消就退出
           
        3. 错误流程
     
           1. 多线程开启，并在线程中写上线程休眠代码
           2. 线程进行判断是否被取消，被取消就退出
           3. 线程执行到休眠代码，停止执行
           4. 点击屏幕，将为完成的线程设为取消状态
           5. 休眠结束，继续执行线程
     
     */
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
