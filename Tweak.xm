#import <Foundation/Foundation.h>

static NSError *OfflineError(void)
{
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:NSURLErrorNotConnectedToInternet
                           userInfo:@{
        NSLocalizedDescriptionKey:
            @"The Internet connection appears to be offline."
    }];
}

%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
{
    NSLog(@"[DisconnectAppNetwork] dataTaskWithRequest: %@",
          request.URL.absoluteString);
    return nil;
}

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url
{
    NSLog(@"[DisconnectAppNetwork] dataTaskWithURL: %@", url.absoluteString);
    return nil;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                           completionHandler:
    (void (^)(NSData *, NSURLResponse *, NSError *))completionHandler
{
    NSLog(@"[DisconnectAppNetwork] data request: %@",
          request.URL.absoluteString);

    if (completionHandler) {
        NSError *error = OfflineError();

        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, nil, error);
        });
    }

    return nil;
}

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url
                       completionHandler:
    (void (^)(NSData *, NSURLResponse *, NSError *))completionHandler
{
    NSLog(@"[DisconnectAppNetwork] data URL: %@", url.absoluteString);

    if (completionHandler) {
        NSError *error = OfflineError();

        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, nil, error);
        });
    }

    return nil;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                        fromData:(NSData *)bodyData
{
    NSLog(@"[DisconnectAppNetwork] upload: %@",
          request.URL.absoluteString);
    return nil;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                        fromData:(NSData *)bodyData
                               completionHandler:
    (void (^)(NSData *, NSURLResponse *, NSError *))completionHandler
{
    NSLog(@"[DisconnectAppNetwork] upload with handler: %@",
          request.URL.absoluteString);

    if (completionHandler) {
        NSError *error = OfflineError();

        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, nil, error);
        });
    }

    return nil;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:
    (NSURLRequest *)request
{
    NSLog(@"[DisconnectAppNetwork] download: %@",
          request.URL.absoluteString);
    return nil;
}

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url
{
    NSLog(@"[DisconnectAppNetwork] download URL: %@",
          url.absoluteString);
    return nil;
}

%end

%hook NSURLSessionTask

- (void)resume
{
    NSURLRequest *request = self.currentRequest ?: self.originalRequest;

    NSLog(@"[DisconnectAppNetwork] Blocking resume: class=%@ URL=%@",
          NSStringFromClass([self class]),
          request.URL.absoluteString);

    [self cancel];
}

%end

%ctor
{
    NSLog(@"[DisconnectAppNetwork] Tweak loaded successfully");
}
