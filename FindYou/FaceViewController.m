#import "FaceViewController.h"
#import "PhotoViewController.h"

static NSString *CellIdentifier = @"Cell";

#define SEP_SIZE 4

@interface DownloadObj : NSObject

@property(nonatomic, retain)UIImageView    *imageView;
@property(nonatomic, retain)NSString       *url;

@end

@implementation DownloadObj

@end

@implementation FaceViewCell
{
    UIImageView *image[3];
    UIButton *menuBtn[3];
}

- (void)setImage:(UIImage *)img byIndex:(int)index
{
    image[index].image = img;
}

- (UIImageView*)getImageView:(int)index
{
    return image[index];
}

- (UIButton*)getMenu:(int)index
{
    return menuBtn[index];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    for (int i = 0; i < 3; ++i) {
        image[i] = [[UIImageView alloc] initWithFrame:CGRectMake(i*((320-SEP_SIZE*2)/3+SEP_SIZE), 0, (320-SEP_SIZE*2)/3, 115)];
        [self addSubview:image[i]];
        
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleTap];
        singleTap.delegate = self;
        singleTap.cancelsTouchesInView = NO;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handLongPress:)];
        [self addGestureRecognizer:longPress];
        longPress.delegate = self;
        longPress.cancelsTouchesInView = NO;
        
        UIImage *image_btn = [UIImage imageNamed:@"menu.png"];
        menuBtn[i] = [[UIButton alloc] initWithFrame:CGRectMake(6, 15, image_btn.size.width, image_btn.size.height)];
        [menuBtn[i] setBackgroundImage:image_btn forState:UIControlStateNormal];
        [menuBtn[i] setTitle:@"查看所有人脸" forState: UIControlStateNormal];
        [menuBtn[i].titleLabel setFont:[UIFont systemFontOfSize:15]];
        [menuBtn[i] addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [image[i] addSubview:menuBtn[i]];
        menuBtn[i].alpha = 0.0f;
        image[i].userInteractionEnabled = YES;
    }
    
    return self;
}

-(void)hideMenu
{
    self.faceViewController.selectedCell = nil;
    for (int i = 0; i < 3; ++i) {
        [UIView animateWithDuration:0.35f animations:^ {
            [self getMenu:i].alpha = 0.0f;
                    } completion:^(BOOL finished) {
            if (finished) {
                
            }
        }];
    }
}

-(void)onBtnClick:(id)sender
{
    int index = 0;
    for (int i = 0; i < 3; ++i) {
        if ([self.faceViewController.selectedCell getMenu:i].alpha != 0.0) {
            index = self.row*3+i;
            break;
        }
    }
    [self.faceViewController.selectedCell hideMenu];
    [self.faceViewController showDetailImageView:index];
}

-(void)handLongPress:(UITapGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateEnded) {
        CGPoint point = [sender locationInView:self];
        int colunm = point.x /100;
        UIButton *btn = [self getMenu:colunm];
        
        if (self.faceViewController.selectedCell != nil) {
            [self.faceViewController.selectedCell hideMenu];
        }
        
        [UIView animateWithDuration:0.35f animations:^ {
            btn.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                
            }
        }];
        
        self.faceViewController.selectedCell = self;
    }
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    int colunm = point.x /100;
    
    if (self.faceViewController.selectedCell == self) {
        for (int i = 0; i < 3; ++i) {
            if ([self.faceViewController.selectedCell getMenu:i].alpha == 1.0f) {
                if (colunm == i) {
                    
                    return;
                }
            }
        }
    }
    
    [self.faceViewController.selectedCell hideMenu];
    int index = self.row*3+colunm;
    [self.faceViewController showFaceView:index];
}

@end

@implementation FaceViewController
{
    NSOperationQueue *operationQueue;
    NSMutableDictionary *faceDict;
    Network *network;
    PhotoViewController *photoView;
    
    NSMutableArray *detailArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.navigationBarHidden = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    faceDict = [NSMutableDictionary dictionary];
    self.navigationController.title = self.name;
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:5];

    self.title = self.name;
    detailArray = [NSMutableArray array];
    
    //###request faces detail file name
    photoView = [[PhotoViewController alloc] initPhotoView];
    photoView.displayActionButton = YES;
    photoView.displayNavArrows = NO;
    photoView.wantsFullScreenLayout = YES;
    photoView.zoomPhotosToFill = YES;
    
    network = [[Network alloc] init];
    network.delegate = self;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"search_all_image" forKey:@"type"];
    [dict setObject:self.name forKey:@"name"];
    [network httpRequest:FACE_URL params:dict];
}

- (void)showDetailImageView:(int)index
{
    NSString *photo_name = [NSString stringWithFormat:@"%@\n", [detailArray objectAtIndex:0]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"search_face" forKey:@"type"];
    [dict setObject:photo_name forKey:@"name"];
    [network httpRequest:FACE_URL params:dict];
}

- (void)showFaceView:(int)index
{
    photoView.index = index;
    
    [photoView setCurrentPhotoIndex:photoView.index];
    [self.navigationController pushViewController:photoView animated:YES];
}

- (void)onRecv:(NSString*)data
{
    data = [data stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    NSArray *array = [data componentsSeparatedByString:@"\n"];
    if (array && [array count] > 0) {
        NSString *protocol = [array objectAtIndex:0];
        if ([protocol isEqualToString:@"search_all_image"]) {
            for (int i = 1; i < [array count]-1; ++i) {
                NSMutableString *url = [NSMutableString stringWithString:FACE_URL];
                [url appendString:@"/"];
                [url appendString:[array objectAtIndex:i]];
                NSString* encodedString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [photoView.photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:encodedString]]];
                
                [detailArray addObject:[array objectAtIndex:i]];
            }
        }
        else if ([protocol isEqualToString:@"search_face"]) {
            int a = 0;
            int b = 0;
            a = b;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int nRow = self.faceQuantity/3;
    if ((self.faceQuantity%3) != 0) {
        nRow++;
    }
    return nRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 119;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FaceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[FaceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.row = (int)indexPath.row;
    cell.faceViewController = self;
    
    int index = (int)indexPath.row*3;
    for (int i = 0; i < 3; ++i) {
        if (index >= 0 && index < self.faceQuantity) {
            NSString *stIndex = [NSString stringWithFormat:@"%d", index+i];
            NSMutableString *url = [NSMutableString stringWithString:FACE_URL];
            [url appendString:@"/faces/"];
            [url appendString:self.name];
            [url appendString:@"/"];
            [url appendString:stIndex];
            [url appendString:@".jpg"];
            NSString* encodedString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            UIImage *image = [faceDict objectForKey:encodedString];
            [cell setImage:nil byIndex:i];
            
            if (image) {
                [cell setImage:image byIndex:i];
            }
            else {

                DownloadObj *obj = [[DownloadObj alloc] init];
                obj.imageView = [cell getImageView:i];
                obj.url = encodedString;
                NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                 selector:@selector(downloadImage:) object:obj];
                [operationQueue addOperation:op];
            }
        }
    }
    
    return cell;
}

- (void)downloadImage:(id)obj
{
    DownloadObj *download = (DownloadObj*)obj;
    NSURL *imageUrl = [NSURL URLWithString:download.url];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (image && download.imageView.image==nil) {
            download.imageView.image = image;
           [faceDict setObject:image forKey:download.url];
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.selectedCell hideMenu];
}

@end
