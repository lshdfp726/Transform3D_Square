//
//  ViewController.m
//  Transform3D_square
//
//  Created by fns on 2017/8/12.
//  Copyright © 2017年 lsh726. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

#define MOVESPACE 50

#define LIGHT_DIRECTION 0, 1, -0.5
#define AMBIENT_LIGHT 0.2

@interface ViewController ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *arrayView;
@property (weak, nonatomic) IBOutlet UIView *contantView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor grayColor];
    
    
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34  = -1 /500.0;
    self.contantView.layer.sublayerTransform = perspective;//子视图layer 的3D参数变换先设置好
    
    //add cube face 1
    CATransform3D transform = CATransform3DMakeTranslation(0, 0, MOVESPACE);
    [self addFace:0 withTransform:transform];
    //add cube face 2
    transform = CATransform3DMakeTranslation(MOVESPACE, 0, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    [self addFace:1 withTransform:transform];
    
    //add cube face 3
    transform = CATransform3DMakeTranslation(-MOVESPACE, 0, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
    [self addFace:2 withTransform:transform];
    
    //add cube face 4
    transform = CATransform3DMakeTranslation(0, MOVESPACE, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 1, 0, 0);
    [self addFace:3 withTransform:transform];
    
    //add cube face 5
    transform = CATransform3DMakeTranslation(0 , 0, -MOVESPACE);
    [self addFace:4 withTransform:transform];
    
    //add cube face 6
    transform = CATransform3DMakeTranslation(0, -MOVESPACE, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
    [self addFace:5 withTransform:transform];
    
    perspective = CATransform3DRotate(perspective, -M_PI_4, 1, 0, 0);
    perspective = CATransform3DRotate(perspective, -M_PI_4, 0, 1, 0);
    self.contantView.layer.sublayerTransform = perspective;

}


//移动视图到对应的位置
- (void)addFace:(NSInteger)index withTransform:(CATransform3D)transform {
    UIView *v = self.arrayView[index];
    [self.contantView addSubview:v];
    
    CGSize contentSize = self.contantView.bounds.size;
    v.center = CGPointMake(contentSize.width/2, contentSize.height/2);
    v.layer.transform = transform;
    v.layer.doubleSided = NO;//不进行双面渲染
    [self addLightingToFace:v.layer];
}


//增加光感
- (void)addLightingToFace:(CALayer *)face {
    CALayer *layer = [CALayer layer];
    layer.frame = face.frame;
    [face addSublayer:layer];
    
    CATransform3D transform = face.transform;
    //martix4 结构和transform3D 一样，进去可以看到martix4式float，transform3D是CGFloat
    GLKMatrix4 matrix4 = GLKMatrix4Make(transform.m11, transform.m12, transform.m13, transform.m14, transform.m21, transform.m22, transform.m23, transform.m24, transform.m31, transform.m32, transform.m33, transform.m34, transform.m41, transform.m42, transform.m43, transform.m44);
    GLKMatrix3 martix3 = GLKMatrix4GetMatrix3(matrix4);
    
    GLKVector3 normal  = GLKVector3Make(0, 0.2, 0.5);//创建一个正常的垂直于z轴的视野向量，可以理解为摄像机的方向
    normal = GLKMatrix3MultiplyVector3(martix3, normal);//3*3矩阵 相乘的到z轴的向量
    normal = GLKVector3Normalize(normal);//返回一个和参数向量的方向一样但是长度为单位1 的向量
    
    GLKVector3 light = GLKVector3Normalize(GLKVector3Make(LIGHT_DIRECTION));//创建一个光源向量
    float dotProduct = GLKVector3DotProduct(light, normal);//视野和光源向量进行相乘的出热点（可以理解为人看到的亮度）
    CGFloat shadow = 1 + dotProduct - AMBIENT_LIGHT; //看到阴影的热点
    UIColor *color = [UIColor colorWithWhite:dotProduct alpha:shadow];//此方法是计算一个颜色由白到灰，根据热点和阴影热点计算出来
    layer.backgroundColor = color.CGColor;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
