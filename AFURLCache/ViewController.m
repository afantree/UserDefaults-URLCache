//
//  ViewController.m
//  AFURLCache
//
//  Created by 阿凡树 QQ：729397005 on 14-5-19.
//  Copyright (c) 2014年 ManGang. All rights reserved.
//

#import "ViewController.h"
#import "AFURLCache.h"
#import "AFUserDefaults.h"
@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Home = %@",NSHomeDirectory());
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path =[documentsDirectory stringByAppendingPathComponent:@"test.sqlite"];
    FMDatabaseQueue* queue = [[FMDatabaseQueue alloc] initWithPath:path];
    [AFURLCache createWithFMDatabaseQueue:queue];
    [AFUserDefaults createWithFMDatabaseQueue:queue];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [button setBackgroundColor:[UIColor redColor]];
    [button setTitle:@"点击" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(100, 240, 100, 100)];
    [button setBackgroundColor:[UIColor redColor]];
    [button setTitle:@"点击" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
-(void)buttonPressed
{
    [AFURLCACHE updateURLCache];
}
-(void)buttonPressed1
{
    [AFUSERDEFAULTS setObject:@"hehe" forKey:@"h"];
    NSLog(@"%@",[AFUSERDEFAULTS objectForKey:@"h"]);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
