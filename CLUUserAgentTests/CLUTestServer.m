//
//  CLUTestServer.m
//  CLUUserAgent
//
//  Created by Sven Herzberg on 27.06.15.
//  Copyright (c) 2015 Sven Herzberg. All rights reserved.
//

#import "CLUTestServer.h"

// @import Darwin.POSIX.arpa.inet;  // inet_ntop()
@import Darwin.POSIX.netdb;      // gethostbyaddr()
@import Darwin.POSIX.netinet.in; // struct sockaddr_in6
@import Darwin.POSIX.sys.socket; // socket()

#import "CLUHTTPMessage.h"

// A simple wrapper around NSFileHandle implementing NSCopying
@interface CLUTestServerSocket : NSObject<NSCopying>
@property (nonnull) NSFileHandle* fileHandle;
@end

@implementation CLUTestServerSocket

+ (instancetype) socketWithFileHandle:(NSFileHandle*)fileHandle
{
    return [[self alloc] initWithFileHandle:fileHandle];
}

- (instancetype) initWithFileHandle:(NSFileHandle*)fileHandle
{
    self = [super init];
    self.fileHandle = fileHandle;
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[self.class allocWithZone:zone] initWithFileHandle:self.fileHandle];
}

@end

@interface CLUTestServer ()

@property (nonnull) NSNotificationCenter* notificationCenter;
@property (nonnull) NSMutableDictionary*  observers;
@property (nullable) NSFileHandle*        v6Handle;
@property (nullable) id<NSObject>         v6Observer;

@end

@implementation CLUTestServer

- (instancetype)init
{
    self = [super init];
    self.notificationCenter = [NSNotificationCenter defaultCenter];
    return self;
}

- (void)dealloc
{
    if (self.v6Observer) {
        [self.notificationCenter removeObserver:self.v6Observer name:NSFileHandleConnectionAcceptedNotification object:self.v6Handle];
    }
    
    for (CLUTestServerSocket* s in self.observers) {
        [self.notificationCenter removeObserver:self.observers[s] name:NSFileHandleReadCompletionNotification object:s.fileHandle];
    }
}

- (nullable NSURL *)listenAndReturnError:(NSError * __nullable __autoreleasing * __nullable)error
{
    int fd = 0;
    int status = 0;
    // 1: Socket Setup
    fd = socket(PF_INET6, SOCK_STREAM, 0);
    if (fd < 0) {
        *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                     code:errno
                                 userInfo:@{@"info": @"Error creating socket."}];
        return nil;
    }
    NSFileHandle* handle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
    
    // 2a: Bind to localhost for IPv6
    struct sockaddr_in6 addr6 = {
        sizeof(addr6),
        AF_INET6,
        .sin6_port = 0,
        .sin6_flowinfo = 0,
        IN6ADDR_LOOPBACK_INIT,
        .sin6_scope_id = 0
    };
    status = bind(fd, (const struct sockaddr*)&addr6, sizeof(addr6));
    if (status < 0) {
        *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                     code:errno
                                 userInfo:@{@"info": @"Error binding socket to localhost (IPv6)."}];
        return nil;
    }
    
#warning FIXME: Provide a legacy IPv4 connection handler as well.
#if 0
    // 2b: Bind to localhost for IPv4
    struct in6_addr v4mapped = IN6ADDR_V4MAPPED_INIT;
    in_addr_t loopback = INADDR_LOOPBACK;
    assert(sizeof(v4mapped) >= sizeof(loopback));
    memcpy(&v4mapped + sizeof(v4mapped) - sizeof(loopback), &loopback, sizeof(loopback));
    addr6.sin6_addr = v4mapped;
    status = bind(fd, (const struct sockaddr*)&addr6, sizeof(addr6));
    if (status < 0) {
        *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                     code:errno
                                 userInfo:@{@"info": @"Error binding socket to localhost (IPv4)."}];
        return nil;
    }
#endif
    
    // 3: Listen for Incoming Connections
    status = listen(fd, 1);
    if (status < 0) {
        *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                     code:errno
                                 userInfo:@{@"info": @"Error listening to socket."}];
        return nil;
    }
    
    struct sockaddr_storage sa;
    socklen_t sa_len = sizeof(sa);
    status = getsockname(fd, (struct sockaddr*)&sa, &sa_len);
    if (status < 0) {
        *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                     code:errno
                                 userInfo:@{@"info": @"Error binding socket to a name."}];
        return nil;
    }
    
    char const* hostname = NULL;
    uint16_t port = 0;
    
    switch (sa.ss_family) {
            
        case AF_INET: {
            NSAssert(sa.ss_len == sizeof(struct sockaddr_in), nil);
            struct sockaddr_in* addr = (void*)&sa;
            if (addr->sin_addr.s_addr == INADDR_ANY) {
                addr->sin_addr.s_addr = INADDR_LOOPBACK;
            }
            struct hostent* he = gethostbyaddr(&(addr->sin_addr), sizeof(addr->sin_addr), sa.ss_family);
            if (!he) {
                *error = [NSError errorWithDomain:@"FIXME" code:h_errno userInfo:@{NSLocalizedDescriptionKey: @(hstrerror(h_errno))}];
                return nil;
            }
            hostname = he->h_name;
            port = addr->sin_port;
            break;
        }
            
        case AF_INET6: {
            NSAssert(sa.ss_len == sizeof(struct sockaddr_in6), nil);
            struct sockaddr_in6* addr6 = (void*)&sa;
            struct hostent* he = gethostbyaddr(&(addr6->sin6_addr), sizeof(addr6->sin6_addr), sa.ss_family);
            if (!he) {
                *error = [NSError errorWithDomain:@"FIXME" code:h_errno userInfo:@{NSLocalizedDescriptionKey: @(hstrerror(h_errno))}];
                return nil;
            }
            hostname = he->h_name;
#if 0
            for (char *const* iter = he->h_aliases; iter && *iter; iter++) {
                NSLog(@"alias: %s", *iter);
            }
#endif
#if 0
            char buf[INET6_ADDRSTRLEN];
            hostname = inet_ntop(sa.ss_family, &(addr6->sin6_addr), buf, sizeof(buf));
            if (!hostname) {
                *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{@"info": @"error getting ip string"}];
                return nil;
            }
#endif
            port = addr6->sin6_port;
            break;
        }
            
        default:
            NSLog(@"%s:%d: FIXME: Add support for address family: 0x%x", __FILE__, __LINE__, sa.ss_family);
            errno = EPROTOTYPE;
            return 0;
            
    }
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    CLU_WEAKEN(self);
    self.v6Observer = [nc addObserverForName:NSFileHandleConnectionAcceptedNotification object:handle queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        CLU_STRENGTHEN(self);
        if (!self) {
            return;
        }
        
        NSFileHandle* connection = notification.userInfo[NSFileHandleNotificationFileHandleItem];
        [self __acceptConnection:connection];
        [notification.object acceptConnectionInBackgroundAndNotify];
    }];
    
    [handle acceptConnectionInBackgroundAndNotify];
    self.v6Handle = handle;
    
    NSURLComponents* result = [[NSURLComponents alloc] init];
    result.scheme = @"http"; // FIXME: Consider a constant here.
    result.host = @(hostname);
    result.port = @(htons(port));
    result.path = @"/";
    return [result URL];
}

- (void) __acceptConnection:(NSFileHandle*)connection
{
    CLU_WEAKEN(self);
    
#warning FIXME: What is the difference between NSFileHandleDataAvailableNotification and NSFileHandleReadCompletionNotification?
#warning FIXME: Consider adding NSFileHandleReadToEndOfFileCompletionNotification for cleanup.
    id<NSObject> observer = [self.notificationCenter addObserverForName:NSFileHandleReadCompletionNotification object:connection queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        CLU_STRENGTHEN(self);
        NSData* data = notification.userInfo[NSFileHandleNotificationDataItem];
        [self __connection:connection hasData:data];
    }];
    self.observers[[CLUTestServerSocket socketWithFileHandle:connection]] = observer;
    [connection readInBackgroundAndNotify];
}

- (void) __connection:(NSFileHandle*)connection hasData:(NSData*)data
{
    CLUHTTPMessage* request = [CLUHTTPMessage messageForEmptyRequest];
    NSRange parsed = [request rangeOfAppendedDataFrom:data];
    NSAssert(parsed.location == 0, nil);
    NSAssert(parsed.length == data.length, nil);
    
    if (!request.headerComplete) {
        @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement! (Persist the request and wait for more data.)" userInfo:nil];
    }
    
    if (![kHTTPMethodGet isEqualToString:request.HTTPMethod]) {
        @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement! (Reply with “405 Method Not Allowed”.)" userInfo:nil];
    }
    
    if (!request.HTTPBody || 0 < request.HTTPBody.length) {
        @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement! (Reply with “400 Bad Request”)" userInfo:nil];
    }
    
    if (![@"/" isEqualToString:request.URL.path]) {
        @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement! (Reply with “404 Not Found”.)" userInfo:nil];
    }
    
    NSString* userAgent = request.allHTTPHeaderFields[kHTTPHeaderNameUserAgent];
    if (!userAgent) {
        @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement! (Reply with “400 Bad Request“, telling the client to send a User-Agent header.)" userInfo:nil];
    }
    
    if (![kHTTPVersion1_1 isEqualToString:request.HTTPVersion]) {
        @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement! (Reply with “505 HTTP Version Not Supported”.)" userInfo:nil];
    }
    
    CFIndex statusCode = kHTTPStatusCodeOK;
    CLUHTTPMessage* response = [CLUHTTPMessage responseWithStatusCode:statusCode HTTPVersion:request.HTTPVersion];
    NSData* responseBody = [userAgent dataUsingEncoding:NSASCIIStringEncoding];
    NSNumber* contentLength = [NSNumber numberWithUnsignedInteger:responseBody.length];
    [response setValue:contentLength.stringValue forHTTPHeaderField:kHTTPHeaderNameContentLength];
#warning FIXME: Set a Content-Type header: text/plain; charset=UTF-8
#warning FIXME: Test using a UTF-8 User-Agent (which is not ASCII compatible).
    response.HTTPBody = responseBody;
    [connection writeData:[response serializedData]];
    [connection closeFile];
    
#warning FIXME: Check the specifications whether this is correct, then implement the correct way: HTTP 1.0 defaults to "close" and 1.1 to "keep-alive"?
    if ([kHTTPHeaderValueConnectionKeepAlive isEqualToString:request.allHTTPHeaderFields[kHTTPHeaderNameConnection]]) {
        return;
    }
    
    for (CLUTestServerSocket* socket in self.observers) {
        if (socket.fileHandle == connection) {
            [self.notificationCenter removeObserver:self.observers[socket] name:NSFileHandleReadCompletionNotification object:connection];
            [self.observers removeObjectForKey:socket];
            break;
        }
    }
}

@end
