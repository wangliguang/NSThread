//
//  ViewController.m
//  NSThread
//
//  Created by GG on 16/2/18.
//  Copyright © 2016年 GG. All rights reserved.
//

#import "ViewController.h"

#define kUrl @"http://store.storeimages.cdn-apple.com/8748/as-images.apple.com/is/image/AppleInc/aos/published/images/s/38/s38ga/rdgd/s38ga-rdgd-sel-201601?wid=848&hei=848&fmt=jpeg&qlt=80&op_sharpen=0&resMode=bicub&op_usm=0.5,0.5,0,0&iccEmbed=0&layer=comp&.v=1454777389943"

@interface ViewController ()
{
    UIImageView *imageView;
    NSThread *thread;
}

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"多线程加载一张图片";
    self.edgesForExtendedLayout = UIRectEdgeNone;

    /*
     * 1、在self.view上放一个UIImageView试图
     */
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 50, 200, 200)];
    [self.view addSubview:imageView];
    
    
    /*
     * 2、 开辟一条子线程(我这里采用创建并手动开启线程的方式)
     
     * target: 信息发送者
    
     * selector: 方法选择器选择一个方法
     
     * object: 如果上面选择的方法有参数，则object便是这个方法的参数
     
     */
     thread = [[NSThread alloc]initWithTarget:self selector:@selector(downloadImage:) object:kUrl];
    
    //给线程起名字
    thread.name = @"子线程";
    
    // 开启线程
    [thread start];
    

    
}

/*
 * 3、 在`子线程`中将url图片转成image对象
 
 *  downloadImage该方法的参数取决于创建线程时传给object的参数
 
 */
- (void)downloadImage:(NSString *)url{
    
    //将图片的url地址转化为data对象
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:kUrl]];
    
    //将data对象转化为image对象
    UIImage *image = [UIImage imageWithData:data];
    
    //采用睡眠方式模拟1秒网络延迟
    [NSThread sleepForTimeInterval:1];
    
    
    /* 
     * 4. 回到主线程
     
     * 方法updataUI将在主线程中执行
     
     * withObject:updateUI的参数
     
     * waitUntilDone: 设为YES，会阻塞当前子线程，去主线程执行updateUI方法，也就是更新UI，直到UI更新完毕。设为NO,意味着在主线程updateUI方法执行到一半时可能会被打断去做其他线程的工作，也就是说我主线程的UI还没有显示完就程序就跳出了主线程。
     */
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:image waitUntilDone:YES];
    
    
    /*
     
     * 查看打印结果
     
     * number = 1 ：线程的编号，由系统设置，主线程的编号为1
     
     * name = main：指当前所在的线程的名字叫做main,可以自己设置，主线程的名字默认是main，其他线程如果不给他设置名字默认是nil
     
     */
    NSLog(@"downlaodImage方法所在的线程 = %@",[NSThread currentThread]);

     
    
}

/*
 * 5、 在主线程中将image对象给UIImageView试图
 */

- (void)updateUI:(UIImage *)image{
    
    imageView.image = image;
    
    NSLog(@"downlaodImage方法所在的线程 = %@",[NSThread currentThread]);
    
}


@end
