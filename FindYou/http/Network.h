#import <UIKit/UIKit.h>

@protocol NetworkDelegate <NSObject>

@optional

- (void)onRecv:(NSString*)data;

@end

@interface Network : NSObject<NSURLConnectionDataDelegate>

- (void)httpRequest:(NSString*)url
              params:(NSDictionary*)params;

@property (nonatomic, weak) id<NetworkDelegate> delegate;

@end