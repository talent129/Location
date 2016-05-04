//
//  LocationViewController.m
//  CaiLocationDemo
//
//  Created by iMac on 16/5/4.
//  Copyright © 2016年 Cai. All rights reserved.
//

#import "LocationViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationViewController ()<CLLocationManagerDelegate>

//定位 获取所在城市
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIButton *locationButton;

@end

@implementation LocationViewController

- (UIButton *)locationButton
{
    if (!_locationButton) {
        _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _locationButton.frame = CGRectMake(100, 200, 120, 30);
        _locationButton.backgroundColor = [UIColor purpleColor];
        [_locationButton setTitle:@"开始定位" forState:UIControlStateNormal];
        [_locationButton addTarget:self action:@selector(locationButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"定位";
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self.view addSubview:self.locationButton];
    
}

#pragma mark -获取当前城市
- (void)getCurrentLocationCity
{
    //开始定位
    _locationManager = [[CLLocationManager alloc] init];
    //定位精度 可自主选择
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //代理
    _locationManager.delegate = self;
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        [_locationManager requestWhenInUseAuthorization];
    }
    //开始定位
    [_locationManager startUpdatingLocation];
}

#pragma mark -CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *currentLocation = [locations lastObject];//最后一个值为最新定位城市
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    //根据经纬度反向得到位置城市信息
    
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = placemarks[0];
            NSString *currentCity = placeMark.locality;
            if (!currentCity) {
                NSLog(@"无法定位当前城市");
            }
            //获取城市信息后，异步更新界面信息
            NSLog(@"currentCity--%@", currentCity);
            
            [_locationButton setTitle:currentCity forState:UIControlStateNormal];
            
        }else if (error == nil && placemarks.count == 0) {
            NSLog(@"location and error returned");
        }else if (error) {
            NSLog(@"location--error--%@", error);
        }
    }];
    //停止定位
    [manager stopUpdatingLocation];
}

//用此代理方法 获取是否授权给此应用定位
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorString;
    [manager stopUpdatingLocation];
    NSLog(@"Error: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = @"您未授权我们获取您的位置";
            //Access to Location Services denied by user
            //Do something...
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"位置服务不可用";
            //Location data unavailable
            //Do something else...
            break;
        default:
            errorString = @"发生未知错误,不能定位您的位置";
            //An unknown error has occurred
            break;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"定位失败" message:errorString preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancle];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)locationButtonAction
{
    [self getCurrentLocationCity];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
