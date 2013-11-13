#import <UIKit/UIKit.h>
#import "http/Network.h"

@interface DetailViewController : UIViewController<NetworkDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, retain)NSString         *faces;

@property(nonatomic, retain)NSString         *url;

@end
