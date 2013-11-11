#import "Network.h"

@interface Network ()
{
    NSURLConnection *connection;
    NSMutableData *receiveData;
}

@end

@implementation Network

- (void)httpRequest:(NSString*)url
              params:(NSDictionary*)params
{
    NSURL *_url = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    
    if (params != nil) {
        NSMutableString * body = [NSMutableString string];
        for (NSString * key in [params allKeys]) {
            [body appendFormat:@"%@=%@&", key, [params objectForKey:key]];
        }
        NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
    }
    
    connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res allHeaderFields]);
    receiveData = [NSMutableData data];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receiveData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *receiveStr = [[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",receiveStr);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRecv:)]) {
        return [self.delegate onRecv:receiveStr];
    }
}

@end