#import <UIKit/UIKit.h>
#import "http/Network.h"
#import "MWPhotoBrowser/Classes/MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoViewController : MWPhotoBrowser<MWPhotoBrowserDelegate>

- (id)initPhotoView;

@property(nonatomic, assign)int  index;

@property (nonatomic, retain) NSMutableArray *photos;

@property (atomic, strong) ALAssetsLibrary *assetLibrary;
@property (atomic, strong) NSMutableArray *assets;

@end
