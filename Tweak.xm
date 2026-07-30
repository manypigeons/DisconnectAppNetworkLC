#import <Foundation/Foundation.h>

%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                           completionHandler:
    (void (^)(NSData *data,
              NSURLResponse *response,
              NSError *error))completionHandler
{
    NSLog(@"[DisconnectAppNetwork] Blocked request: %@",
          request.URL.absoluteString);

    NSError *networkError =
        [NSError errorWithDomain:NSURLErrorDomain
                            code:NSURLErrorNotConnectedToInternet
                        userInfo:@{
                            NSLocalizedDescriptionKey:
                                @"The Internet connection appears to be offline."
                        }];

    if (completionHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, nil, networkError);
        });
    }

    return nil;
}

%end

%hook NSURLConnection

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(NSURLResponse **)response
                             error:(NSError **)error
{
    NSLog(@"[DisconnectAppNetwork] Blocked synchronous request: %@",
          request.URL.absoluteString);

    if (response) {
        *response = nil;
    }

    if (error) {
        *error = [NSError errorWithDomain:NSURLErrorDomain
                                     code:NSURLErrorNotConnectedToInternet
                                 userInfo:@{
                                     NSLocalizedDescriptionKey:
                                         @"The Internet connection appears to be offline."
                                 }];
    }

    return nil;
}

+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request
                                  delegate:(id)delegate
{
    NSLog(@"[DisconnectAppNetwork] Blocked NSURLConnection: %@",
          request.URL.absoluteString);
    return nil;
}

%end

%ctor {
    NSLog(@"[DisconnectAppNetwork] Tweak loaded successfully");
}
