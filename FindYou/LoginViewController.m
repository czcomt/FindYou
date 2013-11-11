#import <QuartzCore/QuartzCore.h>

#import "THLabel/THLabel.h"

#import "LoginViewController.h"
#import "FaceViewController.h"
#import "PhotoViewController.h"

#define kSearchPosY 515
#define kGray 0.2
#define kKeyboardHeight 240

@interface PeopleInfo:NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int count;

@end

@implementation PeopleInfo

@end

@interface LoginViewController ()
{
    Network *network;
    
    NSMutableArray *nameList;
    UIView *pickView;
    UIPickerView *comBoxPickView;
    
    FaceViewController *faceViewController;
    
    //UIView *maskView;
    
    UIImageView *boardcastView;
    NSTimer *randTimer;
    
    THLabel *hello;
    THLabel *welcome;
    
    UITextField *input;
    UIButton *search;
    
    NSTimer *bgSwitchTimer;
    
    UIImageView *bgImageView;
    UIImage *imageA, *imageB;
}

@end

@implementation LoginViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageA = [UIImage imageNamed:@"signed-out-2.jpg"];
    imageB = [UIImage imageNamed:@"signed-out-3.jpg"];
    
    bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    bgImageView.image = imageA;
    [self.view addSubview:bgImageView];
    
    self.view.backgroundColor =[UIColor blackColor];
    
    /*randTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(tickCount:)  userInfo:nil
                                                repeats:YES];*/
    
    bgSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:6
                                                   target:self
                                                 selector:@selector(onSwitchBg:)  userInfo:nil
                                                  repeats:YES];
    
    [self performSelector:@selector(showLogo) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(showSearch) withObject:nil afterDelay:2.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [bgSwitchTimer invalidate];
    bgSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:6
                                                     target:self
                                                   selector:@selector(onSwitchBg:)  userInfo:nil
                                                    repeats:YES];
    
    bgImageView.alpha = 1.0f;
    bgImageView.image = imageA;
}

- (void)showLogo
{
    hello = [[THLabel alloc] initWithFrame:CGRectMake(19, 33, 70, 40)];
    hello.text = @"你好";
    hello.textColor = [UIColor whiteColor];
    hello.font = [UIFont boldSystemFontOfSize:35];
    [hello setShadowColor:[UIColor colorWithRed:kGray green:kGray blue:kGray alpha:1.0]];
    [hello setShadowOffset:CGSizeMake(0.5f, 1.0)];
    [hello setShadowBlur:2.0];
    [self.view addSubview:hello];
    
    welcome = [[THLabel alloc] initWithFrame:CGRectMake(19, 42+33, 190, 40)];
    welcome.text = @"欢迎来到Find You";
    welcome.textColor = [UIColor whiteColor];
    welcome.font = [UIFont systemFontOfSize:23];
    [welcome setShadowColor:[UIColor colorWithRed:kGray green:kGray blue:kGray alpha:1.0]];
    [welcome setShadowOffset:CGSizeMake(0.5f, 1.0)];
    [welcome setShadowBlur:2.0];
    [self.view addSubview:welcome];
    
    hello.alpha = 0.0f;
    welcome.alpha = 0.0f;
    [UIView animateWithDuration:0.75f animations:^ {
        hello.alpha = 1.0f;
        welcome.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}

- (void)showSearch
{
    input = [[UITextField alloc] initWithFrame:CGRectMake(10, kSearchPosY, 220, 44)];
    UIImage *inputBG = [UIImage imageNamed:@"textfield_bg.png"];
    input.background = [inputBG stretchableImageWithLeftCapWidth:9 topCapHeight:22];
    input.placeholder = @"输入朋友的名字";
    UILabel *paddingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    paddingView.text = @"";
    paddingView.textColor = [UIColor darkGrayColor];
    paddingView.backgroundColor = [UIColor clearColor];
    input.leftView = paddingView;
    input.leftViewMode = UITextFieldViewModeAlways;
    input.text = @"airy";
    [self.view addSubview:input];
    
    search = [[UIButton alloc] initWithFrame:CGRectMake(235, kSearchPosY, 75, 44)];
    [search setTitle:@"搜一搜" forState: UIControlStateNormal];
    search.alpha = 0.8;
    
    [search addTarget:self action:@selector(onSearchClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:search];
    
    UIImage *btn = [UIImage imageNamed:@"confirm.png"];
    UIImage *btn_push = [UIImage imageNamed:@"confirm_push.png"];
    
    [search setBackgroundImage:[btn stretchableImageWithLeftCapWidth:9 topCapHeight:86/4.0] forState:UIControlStateNormal];
    [search setBackgroundImage:[btn_push stretchableImageWithLeftCapWidth:9 topCapHeight:86/4.0] forState:UIControlStateHighlighted];
    
    input.alpha = 0.0f;
    search.alpha = 0.0f;
    [UIView animateWithDuration:1.5f animations:^ {
        input.alpha = 0.9f;
        search.alpha = 0.9f;
    } completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}

- (void)onSwitchBg:(NSTimer *)timer
{
    float alpha = 0.0f;
    if (bgImageView.alpha == 0.0f) {
        alpha = 1.0f;
    }
    [UIView animateWithDuration:1.0f animations:^ {
        bgImageView.alpha = alpha;
    } completion:^(BOOL finished) {
        if (finished) {
            
            if (bgImageView.image == imageA) {
                bgImageView.image = imageB;
            }
            else {
                bgImageView.image = imageA;
            }
            
            [UIView animateWithDuration:1.0f animations:^ {
                bgImageView.alpha = 1.0f-alpha;
            } completion:^(BOOL finished) {
                if (finished) {
                    
                    
                }
            }];
        }
    }];
}

- (void)tickCount:(NSTimer *)timer
{
    int val = rand()%4;
    int dy = rand()%100;
    if (val == 0 && !boardcastView) {
        
        NSArray *array = [NSArray arrayWithObjects:@"zhifubao.png", @"gzhu.png", @"miandexiaoxue.png", @"tencent-qq.png",  nil];
        UIImage *image = [UIImage imageNamed:[array objectAtIndex:rand()%[array count] ]];
        boardcastView = [[UIImageView alloc] initWithFrame:CGRectMake(rand()%100 + 30, rand()%200 + 100, image.size.width, image.size.height)];
        boardcastView.image = image;
        boardcastView.alpha = 0.0f;
        [self.view addSubview:boardcastView];
        
        [UIView animateWithDuration:2.0f animations:^{
            boardcastView.alpha = 0.7f;
        } completion:^(BOOL finished) {
            
        }];
        
        [UIView animateWithDuration:6.0f animations:^{
            CGRect rect = boardcastView.frame;
            rect.origin.y += dy;
            boardcastView.frame = rect;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:2.0f animations:^{
                boardcastView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                
                [boardcastView removeFromSuperview];
                boardcastView = nil;
                
            }];
        }];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25f animations:^ {
        CGRect rectInput = input.frame;
        CGRect rectSearch = search.frame;
        if (input.frame.origin.y > 470) {
            rectInput.origin.y -= kKeyboardHeight;
            rectSearch.origin.y -= kKeyboardHeight;
            input.frame = rectInput;
            search.frame = rectSearch;
        }

    } completion:^(BOOL finished) {
        if (finished) {
            
            
        }
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
}

-(void)onSearchClick:(id)sender
{
    //PhotoViewController *photoView = [[PhotoViewController alloc] initPhotoView];
    //[self.navigationController pushViewController:photoView animated:YES];
    
    if (!network) {
        network = [[Network alloc] init];
        network.delegate = self;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"search_name" forKey:@"type"];
    [dict setObject:input.text forKey:@"name"];
    [network httpRequest:FACE_URL params:dict];
    [input resignFirstResponder];
}

- (void)onRecv:(NSString*)data
{
    NSArray *array = [data componentsSeparatedByString:@"\n"];
    if (array && [array count] > 0) {
        NSString *protocol = [array objectAtIndex:0];
        if ([protocol isEqualToString:@"search_name"]) {
            if ([array count] > 1) {
                nameList = [NSMutableArray array];
                for (int i = 1; i < [array count]; ++i) {
                    NSString *text = [array objectAtIndex:i];
                    NSRange range = [text rangeOfString:@";"];
                    
                    if (range.location == NSNotFound) {//### 未定义的，直接跳过
                        continue;
                    }
                    
                    PeopleInfo *info = [[PeopleInfo alloc] init];
                    info.name = [text substringToIndex:range.location];
                    
                    text = [text substringFromIndex:range.location+1];
                    info.count = [text intValue];
                    [nameList addObject:info];
                }
                
                if ([nameList count] > 0) {
                    [self showPicker];
                }
                else {
                    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"搜索不到联系人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alter show];
                }
            }
        }
        
    }
}

- (void)showPicker
{
    if (!pickView) {
        
        /*maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 3080)];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.0f;
        [[[UIApplication sharedApplication] keyWindow].rootViewController.view addSubview:maskView];*/
        
        CGRect rect = [[UIApplication sharedApplication] keyWindow].frame;
        pickView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height, 320, 217)];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
		toolbar.barStyle = UIBarStyleBlackTranslucent;
		
		UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				  target:nil
																				  action:nil];
		
		UIButton *barBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 57, 32)];
		[barBtn setTitle:@"完成" forState:UIControlStateNormal];
		[barBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
		[barBtn addTarget:self action:@selector(pickerClickDone:) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:barBtn];
		
		NSArray *items = [[NSArray alloc] initWithObjects:flexItem,doneItem,nil];
		toolbar.items = items;
		[pickView addSubview:toolbar];
		
		comBoxPickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolbar.frame.size.height,
                                                                        320, 217-toolbar.frame.size.height+10)];
		comBoxPickView.delegate = self;
		comBoxPickView.showsSelectionIndicator=YES;
        comBoxPickView.backgroundColor = [UIColor whiteColor];
        comBoxPickView.alpha = 0.7f;
		[pickView addSubview:comBoxPickView];
        
		[[[UIApplication sharedApplication] keyWindow].rootViewController.view addSubview:pickView];
    }
    
    [comBoxPickView selectRow:0 inComponent:0 animated:NO];
    [comBoxPickView reloadAllComponents];
    
    [UIView animateWithDuration:0.25f animations:^{
        CGRect rect = [[UIApplication sharedApplication] keyWindow].frame;
		pickView.frame = CGRectMake(0, rect.size.height - 217, 320, 217);
	} completion:^(BOOL finished) {
		
	}];
    
    [self keyboardWillShow:nil];
    
    /*[UIView animateWithDuration:0.25f animations:^{
        maskView.alpha = 0.4f;
	} completion:^(BOOL finished) {
		
	}];*/
}

-(void)pickerClickDone:(id)sender
{
    [UIView animateWithDuration:0.25f animations:^ {
        pickView.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
        CGRect rectInput = input.frame;
        CGRect rectSearch = search.frame;
        rectInput.origin.y += kKeyboardHeight;
        rectSearch.origin.y += kKeyboardHeight;
        input.frame = rectInput;
        search.frame = rectSearch;
    } completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
    
    faceViewController = [[FaceViewController alloc] initWithStyle:UITableViewStylePlain];
    int row = [comBoxPickView selectedRowInComponent:0];
    PeopleInfo *info = [nameList objectAtIndex:row];
    faceViewController.faceQuantity = info.count;
    faceViewController.name = info.name;
    [self.navigationController pushViewController:faceViewController animated:YES];
    
    //maskView.alpha = 0.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [nameList count];
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PeopleInfo *info = [nameList objectAtIndex:row];
    return info.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	//[self.button setTitle:[bankCard objectAtIndex:row] forState: UIControlStateNormal];
}

@end
