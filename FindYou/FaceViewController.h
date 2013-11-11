#import <UIKit/UIKit.h>
#import "http/Network.h"

@class FaceViewController;

@interface FaceViewCell : UITableViewCell<UIGestureRecognizerDelegate>

- (void)setImage:(UIImage *)img byIndex:(int)index;

- (UIImageView*)getImageView:(int)index;

- (UIButton*)getMenu:(int)index;

@property(nonatomic, assign)int       row;
@property(nonatomic, retain)FaceViewController    *faceViewController;

@end

@interface FaceViewController : UITableViewController<NetworkDelegate>

@property(nonatomic, assign)int  faceQuantity;

@property(nonatomic, retain)NSString  *name;

@property(nonatomic, retain)FaceViewCell  *selectedCell;

- (void)showFaceView:(int)index;

- (void)showDetailImageView:(int)index;

@end
