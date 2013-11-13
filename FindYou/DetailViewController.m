#import "DetailViewController.h"
#import "DACircularProgressView.h"
#import "SDWebImageManager.h"

@implementation DetailViewController
{
    UIScrollView *scrollView;
    UIImageView *imageView;
    DACircularProgressView *progressView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.view addSubview:progressView];
    progressView.center = self.view.center;
    
    NSString *str = self.url;
    NSURL *imageURL = [NSURL URLWithString:str];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:imageURL
                     options:0
                    progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         progressView.progress = receivedSize*1.0f/expectedSize;
     }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
    {
        progressView.hidden = YES;
         if (image)
         {
             scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
             imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
             imageView.image = image;
             [scrollView addSubview:imageView];
             scrollView.delegate = self;
             [self.view addSubview:scrollView];
             scrollView.contentSize = image.size;
             
             [self setupFaceWithName];
             
             float minX = 320.0f/image.size.width;
             float minY = 568.0f/image.size.height;
             [scrollView setMinimumZoomScale:minX < minY ? minX : minY];
             [scrollView setMaximumZoomScale:1.0];
             [scrollView setZoomScale:1.0f];
             
             UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
             [scrollView addGestureRecognizer:singleTap];
             singleTap.delegate = self;
             singleTap.cancelsTouchesInView = NO;
         }
     }];
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (void)setupFaceWithName
{
    int width = imageView.image.size.width;
    int height = imageView.image.size.height;
    
    NSArray *array = [self.faces componentsSeparatedByString:@";"];
    for (NSString *user in array) {
        NSArray *userArray = [user componentsSeparatedByString:@"="];
        if ([userArray count] > 1) {
            NSString *name = [userArray objectAtIndex:0];
            NSString *rect = [userArray objectAtIndex:1];
            char _clip[100] = {0};
            strcpy(_clip, [rect UTF8String]);
            int left = 0, top = 0, right = 0, bottom = 0;
            sscanf(_clip+12, "%x", &bottom);_clip[12] = 0;
            sscanf(_clip+8, "%x", &right);_clip[8] = 0;
            sscanf(_clip+4, "%x", &top);_clip[4] = 0;
            sscanf(_clip, "%x", &left);
            
            left   = left * width / 65536;
            top    = top * height / 65536;
            right  = right * width / 65536;
            bottom = bottom * height / 65536;
            
            UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, right-left, bottom-top)];
            view.image = [[UIImage imageNamed:@"face.png"] stretchableImageWithLeftCapWidth:127/4.0 topCapHeight:126/4.0];
            view.alpha = 0.8;
            [imageView addSubview:view];
            //view.backgroundColor = [UIColor redColor];
            
            CGSize size = CGSizeMake(right-left, 1000);
            UIFont *font = [UIFont systemFontOfSize:40];
            CGSize labelSize = [name sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, bottom-top, right-left, labelSize.height)];
            label.text = name;
            label.font = font;
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            label.textColor = [UIColor whiteColor];
            
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //[label setNeedsLayout];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    for (UIView *faceView in imageView.subviews) {
        for (UIView *labelView in faceView.subviews) {
            [labelView.layer setContentsScale:scale*[[UIScreen mainScreen] scale]];
            [labelView.layer setNeedsDisplay];
        }
    }
}


@end