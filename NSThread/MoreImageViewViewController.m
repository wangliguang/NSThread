//
//  MoreImageViewViewController.m
//  NSThread
//
//  Created by GG on 16/2/22.
//  Copyright © 2016年 GG. All rights reserved.
//

#import "MoreImageViewViewController.h"


#define kUrl @"http://store.storeimages.cdn-apple.com/8748/as-images.apple.com/is/image/AppleInc/aos/published/images/s/38/s38ga/rdgd/s38ga-rdgd-sel-201601?wid=848&hei=848&fmt=jpeg&qlt=80&op_sharpen=0&resMode=bicub&op_usm=0.5,0.5,0,0&iccEmbed=0&layer=comp&.v=1454777389943"

@interface MoreImageViewViewController ()
{
    int imageIndex;
}
@end

@implementation MoreImageViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    //创建多个线程
    for (int index = 0; index<6; index++) {
        
        NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(downloadImage:) object:kUrl];
        
        //给线程设置优先级（0-1），优先级越高，被优先调用的几率越高。
//        thread.threadPriority = index/10.0;
        thread.name = [NSString stringWithFormat:@"线程%d",index];
        [thread start];
        
    }
}


//每条线程都会走这个方法，来下载相应的图片，在这里为了方便起见，我采用了同一个url图片
- (void)downloadImage:(NSString *)url{
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:kUrl]];
    
    UIImage *image = [UIImage imageWithData:data];
    
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:image waitUntilDone:YES];
    
    NSThread *thread = [NSThread currentThread];
    NSLog(@"当前线程是 = %@",thread.name);

}


- (void)updateUI:(UIImage *)image{
    
    for (int index = 0; index<6; index++) {
        
        UIImageView *imageView = [self.view viewWithTag:100+index];
        
        imageView.image = image;
    }
    
}




@end
