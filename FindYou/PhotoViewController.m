#import "PhotoViewController.h"

@implementation PhotoViewController
{

}

- (id)initPhotoView
{
    self.photos = [[NSMutableArray alloc] init];
    return [super initWithDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.photos.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}

@end